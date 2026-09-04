# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: Apache-2.0

defmodule Wanda.Executions.Server do
  @moduledoc """
  Represents the execution of the CheckSelection(s) on the target nodes/agents of a cluster
  Orchestrates facts gathering on the targets - issuing execution and receiving back facts - and following check evaluations.
  """

  @behaviour Wanda.Executions.ServerBehaviour

  use GenServer, restart: :transient

  alias Wanda.Catalog.{Check, SelectedCheck}

  alias Wanda.Executions.{
    Evaluation,
    ExcludedCheckResult,
    Gathering,
    Result,
    State,
    Supervisor,
    Target
  }

  alias Wanda.{
    Catalog,
    Executions,
    Messaging
  }

  alias Wanda.EvaluationEngine

  alias Wanda.Executions.Messaging.Publisher

  require Logger
  require Wanda.Executions.Enums.AgentCheckStatus, as: AgentCheckStatus

  @default_target_type "cluster"
  @default_timeout 5 * 60 * 1_000

  @doc """
  Starts a check execution.

  The checks are filtered leveraging the `env` and evaluating the `when` condition using a best-effort approach.
  If non-existing check IDs are provided inside a target, they will get filtered away.
  """
  @impl true
  def start_execution(execution_id, group_id, targets, target_type, env, config \\ []) do
    env = Map.put(env, "target_type", target_type)

    checks =
      targets
      |> Target.get_checks_from_targets()
      |> Catalog.get_checks(env)
      |> Catalog.to_selected_checks(group_id)

    checks_ids = Enum.map(checks, & &1.id)

    targets =
      Enum.map(targets, fn %{checks: target_checks} = target ->
        checks_diff = target_checks -- checks_ids
        %Target{target | checks: target_checks -- checks_diff}
      end)

    maybe_start_execution(execution_id, group_id, targets, checks, env, config)
  end

  @impl true
  def receive_facts(execution_id, group_id, agent_id, facts),
    do: group_id |> via_tuple() |> GenServer.cast({:receive_facts, execution_id, agent_id, facts})

  def start_link(opts) do
    group_id = Keyword.fetch!(opts, :group_id)
    config = Keyword.get(opts, :config, [])

    GenServer.start_link(
      __MODULE__,
      %State{
        execution_id: Keyword.fetch!(opts, :execution_id),
        group_id: group_id,
        targets: Keyword.fetch!(opts, :targets),
        checks: Keyword.fetch!(opts, :checks),
        env: Keyword.fetch!(opts, :env),
        timeout: Keyword.get(config, :timeout, @default_timeout)
      },
      name: via_tuple(group_id)
    )
  end

  @impl true
  def init(%State{execution_id: execution_id} = state) do
    Logger.debug("Starting execution: #{execution_id}", state: inspect(state))

    {:ok, state, {:continue, :start_execution}}
  end

  @impl true
  def handle_continue(
        :start_execution,
        %State{
          execution_id: execution_id,
          group_id: group_id,
          targets: targets,
          checks: checks,
          env: env,
          timeout: timeout
        } = state
      ) do
    engine = EvaluationEngine.new()

    {active_targets, excluded_checks} = evaluate_exclusions(targets, checks, engine)

    specs = SelectedCheck.extract_specs(checks)

    execution_started = Messaging.Mapper.to_execution_started(execution_id, group_id, targets)
    Executions.create_execution!(execution_id, group_id, targets)
    :ok = Messaging.publish(Publisher, "results", execution_started)

    if active_targets == [] do
      # Even with no active targets, we still need to surface the excluded
      # hosts in each check's `agents_check_results` so the UI can list them.
      # We delegate to Evaluation.execute with empty gathered_facts, which
      # will create passing check results containing only excluded agents.
      result =
        Evaluation.execute(execution_id, group_id, checks, %{}, env, excluded_checks, [], engine)

      store_and_publish_execution_result(result, env)
      {:stop, :normal, state}
    else
      :ok = facts_gathering_impl().request_facts(execution_id, group_id, active_targets, specs)

      Process.send_after(self(), :timeout, timeout)

      {:noreply,
       %State{state | engine: engine, targets: active_targets, excluded_checks: excluded_checks}}
    end
  end

  @impl true
  def handle_cast(
        {:receive_facts, execution_id, agent_id, facts},
        %State{execution_id: execution_id, targets: targets} = state
      ) do
    if Gathering.target?(targets, agent_id) do
      continue_or_complete_execution(state, agent_id, facts)
    else
      Logger.warning(
        "Received facts for agent #{agent_id} but it is not a target of this execution",
        facts: inspect(facts)
      )

      {:noreply, state}
    end
  end

  @impl true
  def handle_cast(
        {:receive_facts, execution_id, _, _},
        %State{group_id: group_id} = state
      ) do
    Logger.error("Execution #{execution_id} does not match for group #{group_id}")

    {:noreply, state}
  end

  @impl true
  def handle_info(
        :timeout,
        %State{
          engine: engine,
          execution_id: execution_id,
          group_id: group_id,
          gathered_facts: gathered_facts,
          targets: targets,
          checks: checks,
          env: env,
          agents_gathered: agents_gathered,
          excluded_checks: excluded_checks
        } = state
      ) do
    targets =
      Enum.filter(targets, fn %Target{agent_id: agent_id} ->
        agent_id not in agents_gathered
      end)

    timedout_agents = Enum.map(targets, & &1.agent_id)

    gathered_facts = Gathering.put_gathering_timeouts(gathered_facts, targets)

    result =
      Evaluation.execute(
        execution_id,
        group_id,
        checks,
        gathered_facts,
        env,
        excluded_checks,
        timedout_agents,
        engine
      )

    store_and_publish_execution_result(result, env)

    {:stop, :normal, state}
  end

  defp continue_or_complete_execution(
         %State{
           engine: engine,
           execution_id: execution_id,
           group_id: group_id,
           gathered_facts: gathered_facts,
           targets: targets,
           checks: checks,
           env: env,
           agents_gathered: agents_gathered,
           excluded_checks: excluded_checks
         } = state,
         agent_id,
         facts
       ) do
    gathered_facts = Gathering.put_gathered_facts(gathered_facts, agent_id, facts)
    agents_gathered = [agent_id | agents_gathered]

    state = %State{state | gathered_facts: gathered_facts, agents_gathered: agents_gathered}

    if Gathering.all_agents_sent_facts?(agents_gathered, targets) do
      result =
        Evaluation.execute(
          execution_id,
          group_id,
          checks,
          gathered_facts,
          env,
          excluded_checks,
          [],
          engine
        )

      store_and_publish_execution_result(result, env)

      {:stop, :normal, state}
    else
      {:noreply, state}
    end
  end

  defp store_and_publish_execution_result(%Result{execution_id: execution_id} = result, env) do
    Executions.complete_execution!(execution_id, result)

    target_type = Map.get(env, "target_type", @default_target_type)

    execution_completed = Messaging.Mapper.to_execution_completed(result, target_type)
    :ok = Messaging.publish(Publisher, "results", execution_completed)
  end

  defp evaluate_exclusions(targets, checks, engine) do
    checks_by_id = Map.new(checks, &{&1.id, &1})

    Enum.flat_map_reduce(targets, [], fn %Target{checks: target_checks} = target, excluded_acc ->
      {excluded_checks, active_checks} =
        Enum.split_with(target_checks, fn check_id ->
          check_excluded?(check_id, checks_by_id, target, engine)
        end)

      excluded_results = build_excluded_results(excluded_checks, checks_by_id, target.agent_id)

      if active_checks == [] do
        {[], excluded_results ++ excluded_acc}
      else
        active_target = %Target{target | checks: active_checks}
        {[active_target], excluded_results ++ excluded_acc}
      end
    end)
  end

  defp check_excluded?(check_id, checks_by_id, target, engine) do
    selected_check = Map.fetch!(checks_by_id, check_id)
    evaluate_exclusion(selected_check, target, engine)
  end

  defp evaluate_exclusion(
         %SelectedCheck{spec: %Check{exclude: nil}},
         _target,
         _engine
       ),
       do: false

  defp evaluate_exclusion(
         %SelectedCheck{spec: %Check{id: check_id, exclude: exclude_expr}},
         %Target{agent_id: agent_id, attributes: attributes},
         engine
       ) do
    case EvaluationEngine.eval(engine, exclude_expr, %{"host" => attributes}) do
      {:ok, true} ->
        true

      {:ok, false} ->
        false

      {:ok, other} ->
        Logger.warning(
          "Check #{check_id} exclude predicate for agent #{agent_id} returned non-boolean " <>
            "#{inspect(other)}, keeping pair"
        )

        false

      {:error, reason} ->
        Logger.warning(
          "Check #{check_id} exclude predicate for agent #{agent_id} raised error " <>
            "#{inspect(reason)}, keeping pair"
        )

        false
    end
  end

  defp build_excluded_results(excluded_check_ids, checks_by_id, agent_id) do
    Enum.map(excluded_check_ids, fn check_id ->
      %SelectedCheck{spec: %Check{exclude: exclude_expr}} = Map.fetch!(checks_by_id, check_id)

      %ExcludedCheckResult{
        check_id: check_id,
        agent_id: agent_id,
        status: AgentCheckStatus.excluded(),
        exclude_expression: exclude_expr
      }
    end)
  end

  defp via_tuple(group_id),
    do: {:via, :global, {__MODULE__, group_id}}

  defp facts_gathering_impl,
    do: Application.fetch_env!(:wanda, __MODULE__)[:facts_gathering_impl]

  defp maybe_start_execution(_, _, _, [], _, _), do: {:error, :no_checks_selected}

  defp maybe_start_execution(execution_id, group_id, targets, checks, env, config) do
    case DynamicSupervisor.start_child(
           Supervisor,
           {__MODULE__,
            execution_id: execution_id,
            group_id: group_id,
            targets: targets,
            checks: checks,
            env: env,
            config: config}
         ) do
      {:ok, _} ->
        :ok

      {:error, {:already_started, _}} ->
        {:error, :already_running}

      error ->
        error
    end
  end
end

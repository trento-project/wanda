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
  require Wanda.Executions.Enums.Result, as: ResultEnum

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
      result = %Result{
        execution_id: execution_id,
        group_id: group_id,
        check_results: [],
        excluded_checks: excluded_checks,
        timeout: [],
        result: ResultEnum.passing()
      }

      store_and_publish_execution_result(result, env)
      {:stop, :normal, state}
    else
      facts_gathering_requested =
        Messaging.Mapper.to_facts_gathering_requested(execution_id, group_id, active_targets, specs)

      :ok = Messaging.publish(Publisher, "agents", facts_gathering_requested)

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
      execution_id
      |> Evaluation.execute(group_id, checks, gathered_facts, env, timedout_agents, engine)
      |> Map.put(:excluded_checks, excluded_checks)

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
        execution_id
        |> Evaluation.execute(group_id, checks, gathered_facts, env, engine)
        |> Map.put(:excluded_checks, excluded_checks)

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
    {active_targets_rev, excluded} =
      Enum.reduce(targets, {[], []}, fn target, {active_acc, excluded_acc} ->
        {active_check_ids_rev, excluded_for_target} =
          Enum.reduce(target.checks, {[], []}, fn check_id, {keep, excl} ->
            case Enum.find(checks, &(&1.id == check_id)) do
              nil ->
                {[check_id | keep], excl}

              selected_check ->
                case evaluate_exclude_predicate(selected_check, target, engine) do
                  :excluded -> {keep, [check_id | excl]}
                  :keep -> {[check_id | keep], excl}
                end
            end
          end)

        newly_excluded =
          Enum.map(excluded_for_target, fn check_id ->
            exclude_expr = find_exclude_expression(checks, check_id)

            %ExcludedCheckResult{
              check_id: check_id,
              agent_id: target.agent_id,
              status: :excluded_by_policy,
              exclude_expression: exclude_expr
            }
          end)

        active_target = %Target{target | checks: Enum.reverse(active_check_ids_rev)}
        {[active_target | active_acc], newly_excluded ++ excluded_acc}
      end)

    filtered_targets =
      active_targets_rev
      |> Enum.reverse()
      |> Enum.filter(fn %Target{checks: checks} -> checks != [] end)

    {filtered_targets, excluded}
  end

  defp find_exclude_expression(checks, check_id) do
    case Enum.find(checks, &(&1.id == check_id)) do
      %SelectedCheck{spec: %Check{exclude: expr}} -> expr
      _ -> nil
    end
  end

  defp evaluate_exclude_predicate(
         %SelectedCheck{spec: %Check{exclude: nil}},
         _target,
         _engine
       ),
       do: :keep

  defp evaluate_exclude_predicate(
         %SelectedCheck{spec: %Check{id: check_id, exclude: exclude_expr}},
         %Target{agent_id: agent_id, host_data: host_data},
         engine
       ) do
    case EvaluationEngine.eval(engine, exclude_expr, %{"host" => host_data}) do
      {:ok, true} ->
        :excluded

      {:ok, false} ->
        :keep

      {:ok, other} ->
        Logger.warning(
          "Check #{check_id} exclude predicate for agent #{agent_id} returned non-boolean " <>
            "#{inspect(other)}, keeping pair"
        )

        :keep

      {:error, reason} ->
        Logger.warning(
          "Check #{check_id} exclude predicate for agent #{agent_id} raised error " <>
            "#{inspect(reason)}, keeping pair"
        )

        :keep
    end
  end

  defp via_tuple(group_id),
    do: {:via, :global, {__MODULE__, group_id}}

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

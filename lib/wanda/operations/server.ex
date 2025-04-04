defmodule Wanda.Operations.Server do
  @moduledoc """
  Represents the execution of operations in target agents
  Orchestrates operation executions - issuing operations and receiving back the reports.
  """

  @behaviour Wanda.Operations.ServerBehaviour

  use GenServer, restart: :temporary

  alias Wanda.Operations

  alias Wanda.Operations.{
    AgentReport,
    OperationTarget,
    OperatorError,
    OperatorResult,
    State,
    StepReport,
    Supervisor
  }

  alias Wanda.Operations.Catalog.{Operation, Step}

  alias Wanda.Messaging

  alias Wanda.EvaluationEngine

  alias Wanda.Operations.Messaging.Publisher

  require Wanda.Operations.Enums.OperatorPhase, as: OperatorPhase
  require Wanda.Operations.Enums.Result, as: Result
  require Wanda.Operations.Enums.Status, as: Status

  require Logger

  @timeout_message "Operator execution timed out"

  @impl true
  def start_operation(operation_id, group_id, operation, targets, config \\ [])

  def start_operation(_, _, _, [], _), do: {:error, :targets_missing}

  def start_operation(operation_id, group_id, operation, targets, config) do
    %Operation{required_args: required_args} = operation

    # Check if all targets have the required arguments
    all_arguments_present =
      Enum.all?(targets, fn %OperationTarget{arguments: arguments} ->
        required_args -- Map.keys(arguments) == []
      end)

    maybe_start_operation(
      all_arguments_present,
      operation_id,
      group_id,
      operation,
      targets,
      config
    )
  end

  @impl true
  def receive_operation_reports(operation_id, group_id, step_number, agent_id, operator_result),
    do:
      group_id
      |> via_tuple()
      |> GenServer.cast({:receive_reports, operation_id, agent_id, step_number, operator_result})

  def start_link(opts) do
    group_id = Keyword.fetch!(opts, :group_id)

    GenServer.start_link(
      __MODULE__,
      %State{
        operation_id: Keyword.fetch!(opts, :operation_id),
        group_id: group_id,
        operation: Keyword.fetch!(opts, :operation),
        targets: Keyword.fetch!(opts, :targets),
        current_step_index: 0,
        step_failed: false
      },
      name: via_tuple(group_id)
    )
  end

  @impl true
  def init(%State{operation_id: operation_id} = state) do
    Logger.debug("Starting operation: #{operation_id}", state: inspect(state))

    Process.flag(:trap_exit, true)

    {:ok, state, {:continue, :start_operation}}
  end

  @impl true
  def handle_continue(
        :start_operation,
        %State{
          operation_id: operation_id,
          group_id: group_id,
          targets: targets,
          operation: %Operation{
            id: catalog_operation_id
          }
        } = state
      ) do
    engine = EvaluationEngine.new()
    new_state = initialize_report_results(state)

    Operations.create_operation!(operation_id, group_id, catalog_operation_id, targets)

    operation_started =
      Messaging.Mapper.to_operation_started(operation_id, group_id, catalog_operation_id, targets)

    :ok = Messaging.publish(Publisher, "results", operation_started)

    {:noreply, %State{new_state | engine: engine}, {:continue, :execute_step}}
  end

  @impl true
  def handle_continue(
        :execute_step,
        %State{
          operation_id: operation_id,
          group_id: group_id,
          step_failed: true,
          agent_reports: agent_reports,
          operation: %Operation{
            id: catalog_operation_id
          }
        } = state
      ) do
    Logger.debug("Last step failed in some agent. Stopping operation", state: inspect(state))

    # Start rollback?

    result = evaluate_agent_reports_result(agent_reports)

    Operations.complete_operation!(operation_id, result)

    operation_completed =
      Messaging.Mapper.to_operation_completed(
        operation_id,
        group_id,
        catalog_operation_id,
        result
      )

    :ok = Messaging.publish(Publisher, "results", operation_completed)

    {:stop, :normal, %State{state | status: Status.completed()}}
  end

  @impl true
  def handle_continue(
        :execute_step,
        %State{
          operation: %Operation{
            steps: steps
          },
          current_step_index: current_step_index
        } = state
      )
      when current_step_index < length(steps) do
    Logger.debug("Starting operation step: #{current_step_index}", state: inspect(state))

    %Step{predicate: predicate, operator: operator, timeout: timeout} =
      Enum.at(steps, current_step_index)

    new_state =
      %State{pending_targets_on_step: pending_targets} =
      state
      |> predicate_targets_execution(predicate)
      |> maybe_save_skipped_operation_state()
      |> maybe_request_operation_execution(operator, timeout)
      |> maybe_increase_current_step()
      |> store_agent_reports()

    if pending_targets == [] do
      {:noreply, new_state, {:continue, :execute_step}}
    else
      timer_ref = Process.send_after(self(), :timeout, timeout)
      {:noreply, %State{new_state | timer_ref: timer_ref}}
    end
  end

  @impl true
  def handle_continue(
        :execute_step,
        %State{
          operation_id: operation_id,
          group_id: group_id,
          agent_reports: agent_reports,
          operation: %Operation{
            id: catalog_operation_id
          }
        } = state
      ) do
    Logger.debug("All operation steps completed.", state: inspect(state))

    result = evaluate_agent_reports_result(agent_reports)

    # Result based on evaluation result
    Operations.complete_operation!(operation_id, result)

    operation_completed =
      Messaging.Mapper.to_operation_completed(
        operation_id,
        group_id,
        catalog_operation_id,
        result
      )

    :ok = Messaging.publish(Publisher, "results", operation_completed)

    {:stop, :normal, %State{state | status: Status.completed()}}
  end

  @impl true
  def handle_cast(
        {:receive_reports, operation_id, agent_id, step_number, operator_result},
        %State{
          operation_id: operation_id,
          current_step_index: step_number,
          pending_targets_on_step: targets,
          timer_ref: timer_ref
        } = state
      ) do
    Logger.debug(
      "Operation report received: #{operation_id}, #{agent_id}, #{step_number}",
      state: inspect(state)
    )

    pending_targets = List.delete(targets, agent_id)
    {result, diff, message} = evaluate_operator_result(operator_result)

    new_state =
      %State{state | pending_targets_on_step: pending_targets}
      |> update_report_results(step_number, agent_id, result, diff, message)
      |> maybe_set_step_failed(result)
      |> maybe_increase_current_step()
      |> store_agent_reports()

    if pending_targets == [] do
      Process.cancel_timer(timer_ref)
      {:noreply, new_state, {:continue, :execute_step}}
    else
      {:noreply, new_state}
    end
  end

  @impl true
  def handle_cast(
        {:receive_reports, operation_id, _, step_number, _},
        %State{
          operation_id: operation_id
        } = state
      ) do
    Logger.error("Unexpected step number #{step_number} report received")

    {:noreply, state}
  end

  @impl true
  def handle_cast(
        {:receive_reports, operation_id, _, _, _},
        %State{group_id: group_id} = state
      ) do
    Logger.error("Operation #{operation_id} does not match for group #{group_id}")

    {:noreply, state}
  end

  @impl true
  def handle_info(
        :timeout,
        %State{
          current_step_index: current_step_index,
          pending_targets_on_step: pending_targets_on_step
        } = state
      ) do
    Logger.debug("Timeout reached on step number #{current_step_index}.", state: inspect(state))

    new_state =
      pending_targets_on_step
      |> Enum.reduce(state, fn agent_id, acc ->
        update_report_results(
          acc,
          current_step_index,
          agent_id,
          Result.timeout(),
          nil,
          @timeout_message
        )
      end)
      |> Map.put(:step_failed, true)
      |> store_agent_reports()

    {:noreply, new_state, {:continue, :execute_step}}
  end

  # This terminate is a best-effort approach. terminate/2 is not always called, so some
  # operations might remain as running even if the gen server exited abruptly
  @impl true
  def terminate(
        _,
        %State{
          operation_id: operation_id,
          group_id: group_id,
          status: Status.running(),
          operation: %Operation{
            id: catalog_operation_id
          }
        } = state
      ) do
    Operations.abort_operation!(operation_id)

    operation_completed =
      Messaging.Mapper.to_operation_completed(
        operation_id,
        group_id,
        catalog_operation_id,
        Status.aborted()
      )

    :ok = Messaging.publish(Publisher, "results", operation_completed)

    state
  end

  def terminate(_, state), do: state

  defp maybe_start_operation(false, _, _, _, _, _), do: {:error, :arguments_missing}

  defp maybe_start_operation(true, operation_id, group_id, operation, targets, config) do
    case DynamicSupervisor.start_child(
           Supervisor,
           {__MODULE__,
            operation_id: operation_id,
            group_id: group_id,
            operation: operation,
            targets: targets,
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

  # Initialize operation results as not executed for all steps and agents
  defp initialize_report_results(
         %State{
           targets: targets,
           operation: %Operation{
             steps: steps
           }
         } = state
       ) do
    not_executed_agent_reports =
      Enum.map(targets, fn %OperationTarget{agent_id: agent_id} ->
        %AgentReport{agent_id: agent_id, result: Result.not_executed()}
      end)

    agent_reports =
      steps
      |> Enum.with_index()
      |> Enum.map(fn {_, index} ->
        %StepReport{step_number: index, agents: not_executed_agent_reports}
      end)

    %State{state | agent_reports: agent_reports}
  end

  defp predicate_targets_execution(
         %State{
           engine: engine,
           targets: targets
         } = state,
         predicate
       ) do
    pending_targets =
      Enum.reduce(targets, [], fn %OperationTarget{agent_id: agent_id, arguments: arguments},
                                  acc ->
        if predicate_is_met(engine, predicate, arguments) do
          [agent_id | acc]
        else
          acc
        end
      end)

    %State{state | pending_targets_on_step: pending_targets}
  end

  defp predicate_is_met(_, "*", _), do: true
  defp predicate_is_met(_, "", _), do: true

  defp predicate_is_met(engine, predicate, arguments) do
    case EvaluationEngine.eval(engine, predicate, arguments) do
      {:ok, true} ->
        true

      _ ->
        false
    end
  end

  defp maybe_save_skipped_operation_state(
         %State{
           targets: targets,
           pending_targets_on_step: pending_targets,
           current_step_index: step_number
         } = state
       ) do
    targets
    |> Enum.filter(fn %OperationTarget{agent_id: agent_id} -> agent_id not in pending_targets end)
    |> Enum.reduce(state, fn %OperationTarget{agent_id: agent_id}, acc ->
      update_report_results(acc, step_number, agent_id, Result.skipped(), nil, nil)
    end)
  end

  defp maybe_request_operation_execution(%State{pending_targets_on_step: []} = state, _, _) do
    state
  end

  defp maybe_request_operation_execution(
         %State{
           operation_id: operation_id,
           group_id: group_id,
           targets: targets,
           pending_targets_on_step: pending_targets,
           current_step_index: step_number
         } = state,
         operator,
         timeout
       ) do
    operator_execution_requested =
      Messaging.Mapper.to_operator_execution_requested(
        operation_id,
        group_id,
        step_number,
        operator,
        Enum.filter(targets, fn %OperationTarget{agent_id: agent_id} ->
          agent_id in pending_targets
        end)
      )

    expiration = DateTime.add(DateTime.utc_now(), timeout, :millisecond)

    :ok =
      Messaging.publish(Publisher, "agents", operator_execution_requested, expiration: expiration)

    state
  end

  defp maybe_increase_current_step(
         %State{pending_targets_on_step: [], current_step_index: index} = state
       ),
       do: %State{state | current_step_index: index + 1}

  defp maybe_increase_current_step(state), do: state

  # update_report_results updates the agent report status for the given
  # agent, step_number and result
  defp update_report_results(
         %State{agent_reports: current_agent_reports} = state,
         step_number,
         agent_id,
         result,
         diff,
         message
       ) do
    %StepReport{agents: current_agents} =
      step_to_update = Enum.at(current_agent_reports, step_number)

    updated_agents =
      Enum.map(current_agents, fn
        %AgentReport{agent_id: ^agent_id} = agent_report ->
          %AgentReport{agent_report | result: result, diff: diff, error_message: message}

        agent_report ->
          agent_report
      end)

    updated_agent_reports =
      List.replace_at(current_agent_reports, step_number, %{
        step_to_update
        | agents: updated_agents
      })

    %State{state | agent_reports: updated_agent_reports}
  end

  defp store_agent_reports(
         %State{
           operation_id: operation_id,
           agent_reports: agent_reports
         } = state
       ) do
    Operations.update_agent_reports!(operation_id, agent_reports)

    state
  end

  defp maybe_set_step_failed(state, result)
       when result in [Result.failed(), Result.rolled_back()],
       do: %State{state | step_failed: true}

  defp maybe_set_step_failed(state, _), do: state

  defp evaluate_operator_result(%OperatorResult{diff: %{before: value, after: value} = diff}),
    do: {Result.not_updated(), diff, nil}

  defp evaluate_operator_result(%OperatorResult{diff: diff}), do: {Result.updated(), diff, nil}

  defp evaluate_operator_result(%OperatorError{phase: OperatorPhase.commit(), message: message}),
    do: {Result.rolled_back(), nil, message}

  defp evaluate_operator_result(%OperatorError{message: message}),
    do: {Result.failed(), nil, message}

  defp evaluate_agent_reports_result(agent_reports) do
    agent_reports
    |> Enum.flat_map(fn %{agents: agents} -> agents end)
    |> Enum.map(& &1.result)
    |> Enum.map(&{&1, result_weight(&1)})
    |> Enum.max_by(fn {_, weight} -> weight end)
    |> elem(0)
  end

  defp result_weight(Result.failed()), do: 6
  defp result_weight(Result.rolled_back()), do: 5
  defp result_weight(Result.timeout()), do: 4
  defp result_weight(Result.updated()), do: 3
  defp result_weight(Result.not_updated()), do: 2
  defp result_weight(Result.skipped()), do: 1
  defp result_weight(Result.not_executed()), do: 0

  defp via_tuple(group_id),
    do: {:via, :global, {__MODULE__, group_id}}
end

defmodule Wanda.Operations.Server do
  @moduledoc """
  """

  @behaviour Wanda.Operations.ServerBehaviour

  use GenServer, restart: :transient

  alias Wanda.Operations.{Operation, OperationStep, State, Supervisor}

  alias Wanda.Messaging

  alias Wanda.EvaluationEngine

  require Logger

  @default_timeout 5 * 60 * 1_000

  @impl true
  def start_operation(operation_id, group_id, operation_type, targets, config \\ []) do
    # Get operation with "operation", hardcoded by now
    %Operation{required_args: required_args} = op = get_operation(operation_type)

    # Check if all targets have the required arguments
    all_arguments_present =
      Enum.all?(targets, fn %{arguments: arguments} ->
        required_args -- Map.keys(arguments) == []
      end)

    maybe_start_operation(all_arguments_present, operation_id, group_id, op, targets, config)
  end

  @impl true
  def receive_operation_reports(operation_id, group_id, step_number, agent_id, operation_result),
    do:
      group_id
      |> via_tuple()
      |> GenServer.cast({:receive_reports, operation_id, agent_id, step_number, operation_result})

  def start_link(opts) do
    group_id = Keyword.fetch!(opts, :group_id)
    config = Keyword.get(opts, :config, [])

    GenServer.start_link(
      __MODULE__,
      %State{
        operation_id: Keyword.fetch!(opts, :operation_id),
        group_id: group_id,
        operation: Keyword.fetch!(opts, :operation),
        targets: Keyword.fetch!(opts, :targets),
        timeout: Keyword.get(config, :timeout, @default_timeout),
        current_step_index: 0,
        step_failed: false
      },
      name: via_tuple(group_id)
    )
  end

  @impl true
  def init(%State{operation_id: operation_id} = state) do
    Logger.debug("Starting operation: #{operation_id}", state: inspect(state))

    {:ok, state, {:continue, :start_operation}}
  end

  @impl true
  def handle_continue(
        :start_operation,
        %State{
          operation_id: operation_id,
          group_id: group_id,
          operation: %Operation{
            id: operation_type
          },
          targets: targets
        } = state
      ) do
    engine = EvaluationEngine.new()

    operation_started =
      Messaging.Mapper.to_operation_started(operation_id, group_id, operation_type, targets)

    # :ok = Messaging.publish("results", operation_started)
    :ok = publish("results", operation_started)

    # Handle timeout
    # Process.send_after(self(), :timeout, timeout)

    state =
      state
      |> Map.put(:engine, engine)
      |> initialize_report_results()

    {:noreply, state, {:continue, :execute_step}}
  end

  @impl true
  def handle_continue(
        :execute_step,
        %State{
          operation_id: operation_id,
          group_id: group_id,
          operation: %Operation{
            id: operation_type
          },
          step_failed: true,
          agent_reports: agent_reports
        } = state
      ) do
    Logger.debug("Last step failed in some agent. Stopping operation", state: inspect(state))
    # Maybe start operation rollback?

    evaluated_result = evaluate_result(agent_reports)

    # Store and publish reports
    operation_completed =
      Messaging.Mapper.to_operation_completed(
        operation_id,
        group_id,
        operation_type,
        evaluated_result
      )

    # :ok = Messaging.publish("results", operation_completed)
    :ok = publish("results", operation_completed)

    {:stop, :normal, state}
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

    %OperationStep{predicate: predicate, operator: operator} = Enum.at(steps, current_step_index)

    state =
      %State{pending_targets_on_step: pending_targets} =
      state
      |> predicate_targets_execution(predicate)
      |> maybe_save_skipped_operation_state()
      |> maybe_request_operation_execution(operator)
      |> maybe_increase_current_step()

    if pending_targets == [] do
      {:noreply, state, {:continue, :execute_step}}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_continue(
        :execute_step,
        %State{
          operation_id: operation_id,
          group_id: group_id,
          operation: %Operation{
            id: operation_type
          },
          agent_reports: agent_reports
        } = state
      ) do
    Logger.debug("All steps completed. Reporting result.", state: inspect(state))

    evaluated_result = evaluate_result(agent_reports)

    # Store and publish reports
    operation_completed =
      Messaging.Mapper.to_operation_completed(
        operation_id,
        group_id,
        operation_type,
        evaluated_result
      )

    # :ok = Messaging.publish("results", operation_completed)
    :ok = publish("results", operation_completed)

    {:stop, :normal, state}
  end

  @impl true
  def handle_cast(
        {:receive_reports, operation_id, agent_id, step_number, operation_result},
        %State{
          operation_id: operation_id,
          current_step_index: step_number,
          pending_targets_on_step: targets
        } = state
      ) do
    Logger.debug(
      "Operation report received: #{operation_id}, #{agent_id}, #{step_number}, #{operation_result}",
      state: inspect(state)
    )

    pending_targets = List.delete(targets, agent_id)

    state =
      %State{state | pending_targets_on_step: pending_targets}
      |> update_report_results(step_number, agent_id, operation_result)
      |> maybe_set_step_failed(operation_result)
      |> maybe_increase_current_step()

    if pending_targets == [] do
      {:noreply, state, {:continue, :execute_step}}
    else
      {:noreply, state}
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
        {:receive_reports, operation_id, _, _},
        %State{group_id: group_id} = state
      ) do
    Logger.error("Operation #{operation_id} does not match for group #{group_id}")

    {:noreply, state}
  end

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

  defp initialize_report_results(
         %State{
           targets: targets,
           operation: %Operation{
             steps: steps
           }
         } = state
       ) do
    not_executed_agent_reports =
      Enum.map(targets, fn %{agent_id: agent_id} ->
        %{agent_id: agent_id, result: :not_executed}
      end)

    agent_reports =
      steps
      |> Enum.with_index()
      |> Enum.map(fn {_, index} ->
        %{step_number: index, agents: not_executed_agent_reports}
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
      Enum.reduce(targets, [], fn %{agent_id: agent_id, arguments: arguments}, acc ->
        if predicate_is_met(engine, predicate, arguments) do
          [agent_id | acc]
        else
          acc
        end
      end)

    %State{state | pending_targets_on_step: pending_targets}
  end

  defp predicate_is_met(_, "*", _), do: true

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
    |> Enum.filter(fn %{agent_id: agent_id} -> agent_id not in pending_targets end)
    |> Enum.reduce(state, fn %{agent_id: agent_id}, acc ->
      update_report_results(acc, step_number, agent_id, :skipped)
    end)
  end

  defp maybe_request_operation_execution(%State{pending_targets_on_step: []} = state, _) do
    state
  end

  defp maybe_request_operation_execution(
         %State{
           operation_id: operation_id,
           group_id: group_id,
           current_step_index: step_number,
           targets: targets,
           pending_targets_on_step: pending_agents
         } = state,
         operator
       ) do
    operator_execution_requested =
      Messaging.Mapper.to_operation_execution_requested(
        operation_id,
        group_id,
        step_number,
        operator,
        Enum.filter(targets, fn %{agent_id: agent_id} -> agent_id in pending_agents end)
      )

    # :ok = Messaging.publish("agents", operator_execution_requested)
    :ok = publish("agents", operator_execution_requested)

    state
  end

  defp maybe_increase_current_step(
         %State{pending_targets_on_step: [], current_step_index: index} = state
       ),
       do: %State{state | current_step_index: index + 1}

  defp maybe_increase_current_step(state), do: state

  defp update_report_results(
         %State{agent_reports: current_agent_reports} = state,
         step_number,
         agent_id,
         result
       ) do
    %{agents: current_agents} = step_to_update = Enum.at(current_agent_reports, step_number)

    updated_agents =
      Enum.map(current_agents, fn
        %{agent_id: ^agent_id} = agent_report ->
          %{agent_report | result: result}

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

  # this should check the response type
  defp maybe_set_step_failed(state, result) when result in [:failed, :rolled_back],
    do: %State{state | step_failed: true}

  defp maybe_set_step_failed(state, _), do: state

  defp evaluate_result(agent_reports) do
    agent_reports
    |> Enum.flat_map(fn %{agents: agents} ->
      Enum.map(agents, fn %{result: result} -> result end)
    end)
    |> Enum.map(&{&1, result_weight(&1)})
    |> Enum.max_by(fn {_, weight} -> weight end)
    |> elem(0)
  end

  defp result_weight(:failed), do: 4
  defp result_weight(:rolled_back), do: 3
  defp result_weight(:updated), do: 2
  defp result_weight(:not_updated), do: 1
  defp result_weight(:skipped), do: 0
  defp result_weight(:not_executed), do: 0

  defp via_tuple(group_id),
    do: {:via, :global, {__MODULE__, group_id}}

  defp publish(queue, message) do
    Logger.info("Publish message in #{queue}, #{inspect(message)}")
    Messaging.publish(queue, message)

    :ok
  end

  defp get_operation(_) do
    %Operation{
      id: "abcdef",
      name: "saptune solution",
      required_args: ["solution"],
      steps: [
        %OperationStep{
          operator: "saptune solution",
          predicate: "*"
        },
        %OperationStep{
          operator: "saptune solution 2",
          predicate: "isPrimary == true"
        }
      ]
    }
  end
end

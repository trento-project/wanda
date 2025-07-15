defmodule Wanda.Operations.FakeServer do
  @moduledoc """
  Operations server implementation that does not actually execute anything and just
  returns (fake) random results.
  """

  # alias Wanda.Operations.Catalog.Operation

  @behaviour Wanda.Operations.ServerBehaviour

  # use GenServer, restart: :temporary

  # alias Wanda.Operations

  alias Wanda.Operations

  alias Wanda.Operations.Reporting
  # alias Wanda.Operations.{
  # AgentReport,
  # OperationTarget,
  # OperatorError,
  # OperatorResult,
  # Reporting
  # State
  # StepReport
  # }

  alias Wanda.Operations.Catalog.{Operation, Step}

  alias Wanda.Messaging

  alias Wanda.EvaluationEngine

  alias Wanda.Operations.FakeReports

  alias Wanda.Operations.Messaging.Publisher

  require Logger

  @impl true
  def start_operation(operation_id, group_id, operation, targets, config \\ [])

  def start_operation(_, _, _, [], _), do: {:error, :targets_missing}

  def start_operation(
        operation_id,
        group_id,
        %Operation{
          required_args: required_args
        } = operation,
        targets,
        config
      ) do
    targets
    |> Enum.all?(&(required_args -- Map.keys(&1.arguments) == []))
    |> then(fn
      true -> do_start_operation(operation_id, group_id, operation, targets, config)
      false -> {:error, :arguments_missing}
    end)
  end

  defp do_start_operation(operation_id, group_id, operation, targets, config) do
    %Operation{
      id: catalog_operation_id,
      steps: steps
    } = operation

    engine = EvaluationEngine.new()
    # new_state = initialize_report_results(state)

    Operations.create_operation!(operation_id, group_id, catalog_operation_id, targets)

    operation_started =
      Messaging.Mapper.to_operation_started(operation_id, group_id, catalog_operation_id, targets)

    :ok = Messaging.publish(Publisher, "results", operation_started)

    steps
    |> Enum.with_index()
    # Enum.reduce(...) # reduce instead of each
    |> Enum.each(fn {%Step{
                       name: _name,
                       operator: _operator,
                       predicate: predicate,
                       timeout: _timeout
                     } = _step, index} ->
      agent_reports = FakeReports.get_demo_operation_report()

      Reporting.handle_step(
        engine,
        predicate,
        targets,
        index,
        agent_reports
      )

      Process.sleep(Keyword.get(config, :sleep, 2_000))
      nil
    end)

    # reduced from previous step
    agent_reports = []

    result = Reporting.evaluate_agent_reports_result(agent_reports)
    Operations.update_agent_reports!(operation_id, agent_reports)
    Operations.complete_operation!(operation_id, result)

    operation_completed =
      Messaging.Mapper.to_operation_completed(
        operation_id,
        group_id,
        catalog_operation_id,
        result
      )

    :ok = Messaging.publish(Publisher, "results", operation_completed)
  end

  @impl true
  def receive_operation_reports(
        _operation_id,
        _group_id,
        _step_id,
        _agent_id,
        _operation_result
      ),
      do: :ok
end

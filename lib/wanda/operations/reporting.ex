defmodule Wanda.Operations.Reporting do
  @moduledoc """
  Reporting module for Wanda operations.
  """
  alias Wanda.Operations.{
    AgentReport,
    OperationTarget,
    OperatorError,
    OperatorResult,
    StepReport
  }

  alias Wanda.EvaluationEngine

  require Wanda.Operations.Enums.OperatorPhase, as: OperatorPhase
  require Wanda.Operations.Enums.Result, as: Result

  def initialize_report_results(targets, steps) do
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

    agent_reports
  end

  def evaluate_agent_reports_result(agent_reports) do
    agent_reports
    |> Enum.flat_map(fn %{agents: agents} -> agents end)
    |> Enum.map(& &1.result)
    |> Enum.map(&{&1, result_weight(&1)})
    |> Enum.max_by(fn {_, weight} -> weight end)
    |> elem(0)
  end

  # update_report_results updates the agent report status for the given
  # agent, step_number and result
  def update_report_results(
        current_agent_reports,
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

    List.replace_at(current_agent_reports, step_number, %{
      step_to_update
      | agents: updated_agents
    })
  end

  def handle_step(engine, predicate, targets, current_step, current_agent_reports) do
    engine
    |> predicate_targets_execution(predicate, targets)
    |> track_skipped_targets(targets, current_step, current_agent_reports)
  end

  defp predicate_targets_execution(
         engine,
         predicate,
         targets
       ) do
    Enum.reduce(targets, [], fn %OperationTarget{agent_id: agent_id, arguments: arguments}, acc ->
      if predicate_is_met(engine, predicate, arguments) do
        [agent_id | acc]
      else
        acc
      end
    end)
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

  defp track_skipped_targets(
         pending_targets,
         targets,
         step_number,
         current_agent_reports
       ) do
    updated_reports =
      targets
      |> Enum.filter(&(&1.agent_id not in pending_targets))
      |> Enum.reduce(current_agent_reports, fn %OperationTarget{agent_id: agent_id}, acc ->
        update_report_results(acc, step_number, agent_id, Result.skipped(), nil, nil)
      end)

    {pending_targets, updated_reports}
  end

  defp result_weight(Result.failed()), do: 6
  defp result_weight(Result.rolled_back()), do: 5
  defp result_weight(Result.timeout()), do: 4
  defp result_weight(Result.updated()), do: 3
  defp result_weight(Result.not_updated()), do: 2
  defp result_weight(Result.skipped()), do: 1
  defp result_weight(Result.not_executed()), do: 0

  def evaluate_operator_result(%OperatorResult{diff: %{before: value, after: value} = diff}),
    do: {Result.not_updated(), diff, nil}

  def evaluate_operator_result(%OperatorResult{diff: diff}), do: {Result.updated(), diff, nil}

  def evaluate_operator_result(%OperatorError{phase: OperatorPhase.commit(), message: message}),
    do: {Result.rolled_back(), nil, message}

  def evaluate_operator_result(%OperatorError{message: message}),
    do: {Result.failed(), nil, message}
end

defmodule Wanda.Messaging.Mapper do
  @moduledoc """
  Maps domain structures to integration events.
  """

  alias Wanda.Catalog

  alias Wanda.Execution

  alias Trento.Checks.V1.{
    AgentCheckResult,
    CheckResult,
    ExecutionCompleted,
    ExpectationEvaluation,
    ExpectationEvaluationError,
    ExpectationEvaluations,
    ExpectationResult,
    Fact,
    FactRequest,
    FactsGatheringRequested,
    FactsGatheringRequestedTarget
  }

  def to_facts_gathering_requested(execution_id, group_id, targets, checks) do
    FactsGatheringRequested.new!(
      execution_id: execution_id,
      group_id: group_id,
      targets: Enum.map(targets, &to_facts_gathering_requested_target(&1, checks))
    )
  end

  def to_execution_completed(%Execution.Result{
        execution_id: execution_id,
        group_id: group_id,
        check_results: check_results,
        result: result
      }) do
    ExecutionCompleted.new!(
      execution_id: execution_id,
      group_id: group_id,
      check_results: Enum.map(check_results, &to_check_result/1),
      result: to_result(result)
    )
  end

  defp to_facts_gathering_requested_target(
         %Execution.Target{agent_id: agent_id, checks: target_checks},
         checks
       ) do
    fact_requests =
      checks
      |> Enum.filter(&(&1.id in target_checks))
      |> Enum.flat_map(fn %Catalog.Check{id: check_id, facts: facts} ->
        to_fact_requests(check_id, facts)
      end)

    FactsGatheringRequestedTarget.new!(agent_id: agent_id, fact_requests: fact_requests)
  end

  defp to_fact_requests(check_id, facts) do
    Enum.map(facts, fn %Catalog.Fact{name: name, gatherer: gatherer, argument: argument} ->
      FactRequest.new!(check_id: check_id, name: name, gatherer: gatherer, argument: argument)
    end)
  end

  defp to_check_result(%Execution.CheckResult{
         check_id: check_id,
         expectation_results: expectation_results,
         agents_check_results: agents_check_results,
         result: result
       }) do
    CheckResult.new!(
      check_id: check_id,
      agents_check_results: Enum.map(agents_check_results, &to_agent_check_result/1),
      expectation_results: Enum.map(expectation_results, &to_expectation_result/1),
      result: to_result(result)
    )
  end

  defp to_agent_check_result(%Execution.AgentCheckResult{
         agent_id: agent_id,
         facts: facts,
         expectation_evaluations: expectation_evaluations
       }) do
    AgentCheckResult.new!(
      agent_id: agent_id,
      facts: Enum.map(facts, &to_fact/1),
      evaluations: Enum.map(expectation_evaluations, &to_expectation_evaluation/1)
    )
  end

  defp to_fact(%Execution.Fact{} = fact) do
    fact
    |> Map.from_struct()
    |> Fact.new!()
  end

  defp to_expectation_evaluation(%Execution.ExpectationEvaluation{
         name: name,
         return_value: return_value,
         type: type
       }) do
    evaluation_value =
      ExpectationEvaluation.new!(
        name: name,
        return_value: return_value,
        type: to_expectation_type(type)
      )

    ExpectationEvaluations.new!(evaluations: evaluation_value)
  end

  defp to_expectation_evaluation(%Execution.ExpectationEvaluationError{
         name: name,
         message: message,
         type: type
       }) do
    evaluation_error =
      ExpectationEvaluationError.new!(
        name: name,
        message: message,
        type: to_expectation_evaluation_error_type(type)
      )

    ExpectationEvaluations.new!(evaluations: evaluation_error)
  end

  defp to_expectation_result(%Execution.ExpectationResult{
         name: name,
         result: result,
         type: type
       }) do
    ExpectationResult.new!(
      name: name,
      result: result,
      type: to_expectation_type(type)
    )
  end

  defp to_result(:passing), do: :PASSING
  defp to_result(:warning), do: :WARNING
  defp to_result(:critical), do: :CRITICAL

  defp to_expectation_type(:expect), do: :EXPECT
  defp to_expectation_type(:expect_same), do: :EXPECT_SAME

  defp to_expectation_evaluation_error_type(:fact_missing_error), do: :FACT_MISSING_ERROR

  defp to_expectation_evaluation_error_type(:illegal_expression_error),
    do: :ILLEGAL_EXPRESSION_ERROR
end

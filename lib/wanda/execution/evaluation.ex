defmodule Wanda.Execution.Evaluation do
  @moduledoc """
  Evaluation functional core.
  """

  alias Wanda.Catalog.{Check, Expectation}

  alias Wanda.Execution.{
    AgentCheckError,
    AgentCheckResult,
    CheckResult,
    ExpectationEvaluation,
    ExpectationEvaluationError,
    ExpectationResult,
    Fact,
    FactError,
    Result
  }

  # Abacus spec is wrong
  @dialyzer {:nowarn_function, eval_expectation: 2}

  @spec execute(String.t(), String.t(), [Check.t()], map()) :: Result.t()
  def execute(execution_id, group_id, checks, gathered_facts, timeouts \\ []) do
    %Result{
      execution_id: execution_id,
      group_id: group_id,
      timeout: timeouts
    }
    |> add_checks_result(checks, gathered_facts)
    |> aggregate_execution_result()
  end

  defp add_checks_result(%Result{} = result, checks, gathered_facts) do
    check_results =
      Enum.map(gathered_facts, fn {check_id, agents_facts} ->
        %Check{expectations: expectations} = Enum.find(checks, &(&1.id == check_id))

        build_check_result(check_id, expectations, agents_facts)
      end)

    %Result{result | check_results: check_results}
  end

  defp build_check_result(check_id, expectations, agents_facts) do
    %CheckResult{
      check_id: check_id
    }
    |> add_agents_results(expectations, agents_facts)
    |> add_expectation_evaluations(expectations)
    |> aggregate_check_result()
  end

  defp add_agents_results(
         %CheckResult{check_id: check_id} = check_result,
         expectations,
         agents_facts
       ) do
    agents_results =
      Enum.map(agents_facts, fn
        {agent_id, :timeout} ->
          %AgentCheckError{
            agent_id: agent_id,
            type: :timeout,
            message: "Agent timed out during the execution"
          }

        {agent_id, facts} ->
          %AgentCheckResult{agent_id: agent_id}
          |> add_agent_expectation_result(facts, expectations)
          |> add_facts(facts, check_id)
      end)

    %CheckResult{check_result | agents_check_results: agents_results}
  end

  defp add_agent_expectation_result(
         %AgentCheckResult{} = agent_check_result,
         facts,
         expectations
       ) do
    %AgentCheckResult{
      agent_check_result
      | expectation_evaluations: Enum.map(expectations, &eval_expectation(&1, facts))
    }
  end

  defp add_facts(%AgentCheckResult{} = agent_check_result, facts, check_id) do
    %AgentCheckResult{
      agent_check_result
      | facts:
          Enum.map(facts, fn
            {name, %{type: type, message: message}} ->
              %FactError{check_id: check_id, name: name, type: type, message: message}

            {name, value} ->
              %Fact{check_id: check_id, name: name, value: value}
          end)
    }
  end

  defp eval_expectation(
         %Expectation{name: name, type: type, expression: expression},
         facts
       ) do
    case Abacus.eval(expression, facts) do
      {:ok, return_value} ->
        %ExpectationEvaluation{name: name, type: type, return_value: return_value}

      {:error, :einkey} ->
        %ExpectationEvaluationError{
          name: name,
          message: "Fact is not present.",
          type: :fact_missing_error
        }

      _ ->
        %ExpectationEvaluationError{
          name: name,
          message: "Illegal expression provided, check expression syntax.",
          type: :illegal_expression_error
        }
    end
  end

  defp add_expectation_evaluations(
         %CheckResult{agents_check_results: agents_check_results} = result,
         expectations
       ) do
    expectation_results =
      agents_check_results
      |> Enum.filter(fn
        %AgentCheckError{} -> false
        _ -> true
      end)
      |> Enum.flat_map(fn
        %AgentCheckResult{expectation_evaluations: expectation_evaluations} ->
          expectation_evaluations
      end)
      |> Enum.group_by(& &1.name)
      |> Enum.map(fn {name, expectation_evaluations} ->
        type =
          Enum.find_value(expectations, fn
            %Expectation{name: ^name, type: type} -> type
            _ -> false
          end)

        %ExpectationResult{
          name: name,
          type: type,
          result: eval_expectation_result_or_error(type, expectation_evaluations)
        }
      end)

    %CheckResult{result | expectation_results: expectation_results}
  end

  defp eval_expectation_result_or_error(type, expectation_evaluations) do
    if has_error?(expectation_evaluations) do
      false
    else
      eval_expectation_result(type, expectation_evaluations)
    end
  end

  defp has_error?(expectation_evaluations) do
    Enum.any?(expectation_evaluations, fn
      %ExpectationEvaluationError{} -> true
      _ -> false
    end)
  end

  defp eval_expectation_result(:expect_same, expectation_evaluations) do
    expectation_evaluations
    |> Enum.uniq_by(& &1.return_value)
    |> Kernel.length() == 1
  end

  defp eval_expectation_result(:expect, expectations_evaluations) do
    Enum.all?(expectations_evaluations, &(&1.return_value == true))
  end

  defp aggregate_check_result(
         %CheckResult{
           expectation_results: expectation_results,
           agents_check_results: agents_check_results
         } = check_result
       ) do
    result =
      if Enum.all?(expectation_results, &(&1.result == true)) and
           not errors?(agents_check_results) do
        :passing
      else
        :critical
      end

    %CheckResult{check_result | result: result}
  end

  defp aggregate_execution_result(%Result{check_results: check_results} = execution_result) do
    result =
      check_results
      |> Enum.map(& &1.result)
      |> Enum.map(&{&1, result_weight(&1)})
      |> Enum.max_by(fn {_, weight} -> weight end)
      |> elem(0)

    %Result{execution_result | result: result}
  end

  defp errors?(agents_check_results),
    do:
      Enum.any?(agents_check_results, fn
        %AgentCheckError{} -> true
        _ -> false
      end)

  # TODO: is unknown needed?
  # defp result_weight(:unknown), do: 3
  defp result_weight(:critical), do: 2
  defp result_weight(:warning), do: 1
  defp result_weight(:passing), do: 0
end

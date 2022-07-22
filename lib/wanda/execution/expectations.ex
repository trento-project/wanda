defmodule Wanda.Execution.Expectations do
  @moduledoc """
  Expectations functional core.
  """

  alias Wanda.Catalog

  alias Wanda.Execution.{
    AgentCheckResult,
    AgentExpectationResult,
    CheckResult,
    ExpectationResult,
    Result
  }

  # Abacus spec is wrong
  @dialyzer {:nowarn_function, eval_expectation: 2}

  def eval(execution_id, group_id, gathered_facts) do
    %Result{
      execution_id: execution_id,
      group_id: group_id
    }
    |> add_checks_result(gathered_facts)
    |> aggregate_execution_result()
  end

  defp add_checks_result(%Result{} = result, gathered_facts) do
    checks_result =
      Enum.map(gathered_facts, fn {check_id, agents_facts} ->
        build_check_result(check_id, agents_facts)
      end)

    %Result{result | checks_result: checks_result}
  end

  defp build_check_result(check_id, agents_facts) do
    %CheckResult{
      check_id: check_id
    }
    |> add_agents_results(agents_facts)
    |> add_expectations_results()
    |> aggregate_result()
  end

  defp add_agents_results(%CheckResult{check_id: check_id} = check_result, agents_facts) do
    agents_results =
      Enum.map(agents_facts, fn {agent_id, facts} ->
        %AgentCheckResult{agent_id: agent_id, facts: facts}
        |> add_agent_expectation_result(check_id)
      end)

    %CheckResult{check_result | agents_result: agents_results}
  end

  defp add_agent_expectation_result(
         %AgentCheckResult{facts: facts} = agent_check_result,
         check_id
       ) do
    agent_expectations_result =
      check_id
      |> Catalog.get_expectations()
      |> Enum.map(&eval_expectation(&1, facts))

    %AgentCheckResult{agent_check_result | expectations_result: agent_expectations_result}
  end

  defp eval_expectation(%{"name" => name, "expect" => expression}, facts),
    do: eval_per_davvero(name, expression, :expect, facts)

  defp eval_expectation(%{"name" => name, "expect_same" => expression}, facts),
    do: eval_per_davvero(name, expression, :expect_same, facts)

  defp eval_per_davvero(name, expression, type, facts) do
    case Abacus.eval(expression, facts) do
      {:ok, result} ->
        %AgentExpectationResult{name: name, type: type, result: result}

      {:error, :einkey} ->
        %AgentExpectationResult{name: name, type: type, result: :fact_missing_error}

      _ ->
        %AgentExpectationResult{name: name, type: type, result: :illegal_expression_error}
    end
  end

  defp add_expectations_results(%CheckResult{agents_result: agents_result} = result) do
    expectations_result =
      agents_result
      |> Enum.flat_map(fn %AgentCheckResult{expectations_result: expectations_result} ->
        expectations_result
      end)
      |> Enum.group_by(&{&1.name, &1.type})
      |> Enum.map(fn {{name, type}, expectations} ->
        %ExpectationResult{
          name: name,
          type: type,
          result: evaluate_expectations_result(type, expectations)
        }
      end)

    %CheckResult{result | expectations_result: expectations_result}
  end

  defp evaluate_expectations_result(:expect_same, expectations) do
    expectations
    |> Enum.uniq_by(& &1.result)
    |> Kernel.length() == 1
  end

  defp evaluate_expectations_result(:expect, expectations) do
    Enum.all?(expectations, &(&1.result == true))
  end

  defp aggregate_result(%CheckResult{expectations_result: expectations_result} = check_result) do
    result =
      if Enum.all?(expectations_result, &(&1.result == true)) do
        :passing
      else
        :critical
      end

    %CheckResult{check_result | result: result}
  end

  defp aggregate_execution_result(%Result{checks_result: checks_result} = execution_result) do
    result =
      checks_result
      |> Enum.map(& &1.result)
      |> Enum.map(&{&1, result_weight(&1)})
      |> Enum.max_by(fn {_, weight} -> weight end)
      |> elem(0)

    %Result{execution_result | result: result}
  end

  defp result_weight(:unknown), do: 3
  defp result_weight(:critical), do: 2
  defp result_weight(:warning), do: 1
  defp result_weight(:passing), do: 0
end

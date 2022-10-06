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
  @dialyzer {:nowarn_function, eval_expectation: 3, value_from_conditions: 3}

  @spec execute(
          String.t(),
          String.t(),
          [Check.t()],
          %{String.t() => boolean() | number() | String.t()},
          map()
        ) :: Result.t()
  def execute(execution_id, group_id, checks, gathered_facts, env, timeouts \\ []) do
    %Result{
      execution_id: execution_id,
      group_id: group_id,
      timeout: timeouts
    }
    |> add_checks_result(checks, gathered_facts, env)
    |> aggregate_execution_result()
  end

  defp add_checks_result(%Result{} = result, checks, gathered_facts, env) do
    check_results =
      Enum.map(gathered_facts, fn {check_id, agents_facts} ->
        %Check{severity: severity, values: values, expectations: expectations} =
          Enum.find(checks, &(&1.id == check_id))

        build_check_result(check_id, severity, expectations, agents_facts, env, values)
      end)

    %Result{result | check_results: check_results}
  end

  defp build_check_result(check_id, severity, expectations, agents_facts, env, values) do
    %CheckResult{
      check_id: check_id
    }
    |> add_agents_results(expectations, agents_facts, env, values)
    |> add_expectation_evaluations(expectations)
    |> aggregate_check_result(severity)
  end

  defp add_agents_results(
         %CheckResult{} = check_result,
         expectations,
         agents_facts,
         env,
         values
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
          add_agent_check_result_or_error(agent_id, facts, expectations, env, values)
      end)

    %CheckResult{check_result | agents_check_results: agents_results}
  end

  defp add_agent_check_result_or_error(agent_id, facts, expectations, env, values) do
    if has_some_fact_gathering_error?(facts) do
      %AgentCheckError{
        agent_id: agent_id,
        facts: facts,
        type: :fact_gathering_error,
        message: "Fact gathering ocurred during the execution"
      }
    else
      computed_values = compute_values(values, facts, env)

      %AgentCheckResult{
        agent_id: agent_id,
        facts: facts,
        values: computed_values,
        expectation_evaluations:
          Enum.map(expectations, &eval_expectation(&1, facts, computed_values))
      }
    end
  end

  def has_some_fact_gathering_error?(facts) do
    Enum.any?(facts, fn
      %FactError{} -> true
      _ -> false
    end)
  end

  defp eval_expectation(
         %Expectation{name: name, type: type, expression: expression},
         facts,
         values
       ) do
    evaluation_scope = %{
      "facts" => map_facts_to_evaluation_scope(facts),
      "values" => map_values_to_evaluation_scope(values)
    }

    case Abacus.eval(expression, evaluation_scope) do
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
         } = check_result,
         severity
       ) do
    result =
      if Enum.all?(expectation_results, &(&1.result == true)) and
           not errors?(agents_check_results) do
        :passing
      else
        severity
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

  defp compute_values(values, facts, env) do
    Enum.map(values, &value_from_conditions(&1, facts, env))
  end

  defp value_from_conditions(
         %Wanda.Catalog.Value{
           name: name,
           default: default,
           conditions: conditions
         },
         facts,
         env
       ) do
    scoped_facts = map_facts_to_evaluation_scope(facts)

    computed_value =
      Enum.find_value(conditions, default, fn %Wanda.Catalog.Condition{
                                                value: value,
                                                expression: expression
                                              } ->
        case Abacus.eval(expression, %{"facts" => scoped_facts, "env" => env}) do
          {:ok, true} ->
            value

          _ ->
            false
        end
      end)

    %Wanda.Execution.Value{
      name: name,
      value: computed_value
    }
  end

  defp map_facts_to_evaluation_scope(facts) do
    Enum.reduce(facts, %{}, fn %Fact{name: name, value: value}, acc ->
      put_in(acc, [name], value)
    end)
  end

  defp map_values_to_evaluation_scope(values) do
    Enum.reduce(values, %{}, fn %Wanda.Execution.Value{name: name, value: value}, acc ->
      put_in(acc, [name], value)
    end)
  end
end

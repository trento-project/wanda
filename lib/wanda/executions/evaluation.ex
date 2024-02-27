defmodule Wanda.Executions.Evaluation do
  @moduledoc """
  Evaluation functional core.
  """

  alias Wanda.Catalog.{Check, Condition, Expectation}
  alias Wanda.Catalog.Value, as: CatalogValue

  alias Wanda.Executions.{
    AgentCheckError,
    AgentCheckResult,
    CheckResult,
    ExpectationEvaluation,
    ExpectationEvaluationError,
    ExpectationResult,
    FactError,
    Result,
    Value
  }

  alias Wanda.EvaluationEngine

  @default_failure_message "Expectation not met"

  @spec execute(
          String.t(),
          String.t(),
          [Check.t()],
          map(),
          %{String.t() => boolean() | number() | String.t()},
          [String.t()],
          Rhai.Engine.t()
        ) :: Result.t()
  def execute(execution_id, group_id, checks, gathered_facts, env, timeouts \\ [], engine) do
    %Result{
      execution_id: execution_id,
      group_id: group_id,
      timeout: timeouts
    }
    |> add_checks_result(
      checks,
      gathered_facts,
      env,
      engine
    )
    |> aggregate_execution_result()
  end

  defp add_checks_result(%Result{} = result, checks, gathered_facts, env, engine) do
    check_results =
      Enum.map(gathered_facts, fn {check_id, agents_facts} ->
        %Check{severity: severity, values: values, expectations: expectations} =
          Enum.find(checks, &(&1.id == check_id))

        build_check_result(check_id, severity, expectations, agents_facts, env, values, engine)
      end)

    %Result{result | check_results: check_results}
  end

  defp build_check_result(check_id, severity, expectations, agents_facts, env, values, engine) do
    %CheckResult{
      check_id: check_id
    }
    |> add_agents_results(
      expectations,
      agents_facts,
      env,
      values,
      engine
    )
    |> add_expectation_results(expectations, engine)
    |> aggregate_check_result(severity)
  end

  defp add_agents_results(
         %CheckResult{} = check_result,
         expectations,
         agents_facts,
         env,
         values,
         engine
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
          add_agent_check_result_or_error(agent_id, facts, expectations, env, values, engine)
      end)

    %CheckResult{check_result | agents_check_results: agents_results}
  end

  defp add_agent_check_result_or_error(agent_id, facts, expectations, env, values, engine) do
    if has_some_fact_gathering_error?(facts) do
      %AgentCheckError{
        agent_id: agent_id,
        facts: facts,
        type: :fact_gathering_error,
        message: "Fact gathering error occurred during the execution"
      }
    else
      value_evaluation_scope = add_scope(%{"env" => env}, "facts", facts)

      evaluated_values = Enum.map(values, &eval_value(&1, value_evaluation_scope, engine))

      expectation_evaluation_scope =
        %{}
        |> add_scope("facts", facts)
        |> add_scope("values", evaluated_values)

      %AgentCheckResult{
        agent_id: agent_id,
        facts: facts,
        values: evaluated_values,
        expectation_evaluations:
          Enum.map(expectations, &eval_expectation(&1, expectation_evaluation_scope, engine))
      }
    end
  end

  def has_some_fact_gathering_error?(facts) do
    Enum.any?(facts, fn
      %FactError{} -> true
      _ -> false
    end)
  end

  defp add_scope(scope, namespace, namespaced_scope) do
    Map.put(
      scope,
      namespace,
      Enum.into(namespaced_scope, %{}, fn %{name: name, value: value} -> {name, value} end)
    )
  end

  defp eval_value(
         %CatalogValue{
           name: name,
           default: default,
           conditions: conditions
         },
         evaluation_scope,
         engine
       ) do
    %Value{
      name: name,
      value: find_value(conditions, default, evaluation_scope, engine)
    }
  end

  defp find_value(conditions, default, evaluation_scope, engine) do
    Enum.find_value(
      conditions,
      default,
      fn %Condition{
           value: value,
           expression: expression
         } ->
        case EvaluationEngine.eval(engine, expression, evaluation_scope) do
          {:ok, true} ->
            value

          _ ->
            false
        end
      end
    )
  end

  defp eval_expectation(
         %Expectation{
           name: name,
           type: type,
           expression: expression,
           failure_message: failure_message,
           warning_message: warning_message
         },
         evaluation_scope,
         engine
       ) do
    case EvaluationEngine.eval(engine, expression, evaluation_scope) do
      {:ok, return_value} ->
        maybe_add_failure_message(
          %ExpectationEvaluation{
            name: name,
            type: type,
            return_value: normalize_return_value(type, return_value)
          },
          failure_message,
          warning_message,
          evaluation_scope,
          engine
        )

      {:error, {error_type, message}} ->
        %ExpectationEvaluationError{
          name: name,
          message: message,
          type: error_type
        }
    end
  end

  defp normalize_return_value(:expect_enum, "passing"), do: :passing
  defp normalize_return_value(:expect_enum, "warning"), do: :warning
  defp normalize_return_value(:expect_enum, _), do: :critical
  defp normalize_return_value(_, return_value), do: return_value

  defp maybe_add_failure_message(
         %ExpectationEvaluation{type: :expect, return_value: false} = expectation_evaluation,
         nil,
         _warning_message,
         _evaluation_scope,
         _
       ),
       do: %ExpectationEvaluation{
         expectation_evaluation
         | failure_message: @default_failure_message
       }

  defp maybe_add_failure_message(
         %ExpectationEvaluation{type: :expect, return_value: false} = expectation_evaluation,
         failure_message,
         _warning_message,
         evaluation_scope,
         engine
       ),
       do: %ExpectationEvaluation{
         expectation_evaluation
         | failure_message: interpolate_message(failure_message, evaluation_scope, engine)
       }

  defp maybe_add_failure_message(
         %ExpectationEvaluation{type: :expect_enum, return_value: :critical} =
           expectation_evaluation,
         nil,
         _warning_message,
         _evaluation_scope,
         _
       ),
       do: %ExpectationEvaluation{
         expectation_evaluation
         | failure_message: @default_failure_message
       }

  defp maybe_add_failure_message(
         %ExpectationEvaluation{type: :expect_enum, return_value: :critical} =
           expectation_evaluation,
         failure_message,
         _warning_message,
         evaluation_scope,
         engine
       ),
       do: %ExpectationEvaluation{
         expectation_evaluation
         | failure_message: interpolate_message(failure_message, evaluation_scope, engine)
       }

  defp maybe_add_failure_message(
         %ExpectationEvaluation{type: :expect_enum, return_value: :warning} =
           expectation_evaluation,
         _failure_message,
         nil,
         _evaluation_scope,
         _
       ),
       do: %ExpectationEvaluation{
         expectation_evaluation
         | failure_message: @default_failure_message
       }

  defp maybe_add_failure_message(
         %ExpectationEvaluation{type: :expect_enum, return_value: :warning} =
           expectation_evaluation,
         _failure_message,
         warning_message,
         evaluation_scope,
         engine
       ),
       do: %ExpectationEvaluation{
         expectation_evaluation
         | failure_message: interpolate_message(warning_message, evaluation_scope, engine)
       }

  defp maybe_add_failure_message(
         %ExpectationResult{type: :expect_same, result: false} = expectation_result,
         nil,
         _warning_message,
         _evaluation_scope,
         _
       ),
       do: %ExpectationResult{expectation_result | failure_message: @default_failure_message}

  defp maybe_add_failure_message(
         %ExpectationResult{type: :expect_same, result: false} = expectation_result,
         failure_message,
         _warning_message,
         _evaluation_scope,
         _
       ),
       do: %ExpectationResult{expectation_result | failure_message: failure_message}

  defp maybe_add_failure_message(expectation, _, _, _, _), do: expectation

  defp interpolate_message(message, evaluation_scope, engine) do
    case EvaluationEngine.eval(engine, "`#{message}`", evaluation_scope) do
      {:ok, interpolated_failure_message} -> interpolated_failure_message
      _ -> @default_failure_message
    end
  end

  defp add_expectation_results(
         %CheckResult{agents_check_results: agents_check_results} = result,
         expectations,
         engine
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
        %Expectation{type: type, failure_message: failure_message} =
          Enum.find(expectations, fn
            %Expectation{name: ^name} -> true
            _ -> false
          end)

        maybe_add_failure_message(
          %ExpectationResult{
            name: name,
            type: type,
            result:
              eval_expectation_result_or_error(
                type,
                expectation_evaluations,
                agents_check_results
              )
          },
          failure_message,
          nil,
          %{},
          engine
        )
      end)

    %CheckResult{result | expectation_results: expectation_results}
  end

  defp eval_expectation_result_or_error(type, expectation_evaluations, agents_check_results) do
    if has_error?(expectation_evaluations) or
         length(agents_check_results) != length(expectation_evaluations) do
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

  defp eval_expectation_result(:expect_enum, expectations_evaluations) do
    expectations_evaluations
    |> Enum.map(&{&1.return_value, result_weight(&1.return_value)})
    |> Enum.max_by(fn {_, weight} -> weight end)
    |> elem(0)
  end

  defp aggregate_check_result(
         %CheckResult{
           expectation_results: expectation_results,
           agents_check_results: agents_check_results
         } = check_result,
         severity
       ) do
    result =
      if errors?(agents_check_results) do
        Enum.find_value(agents_check_results, severity, fn
          %AgentCheckError{type: :timeout} -> :critical
          _ -> false
        end)
      else
        # Normalize the expectation results to passing/warning/critical and weight them
        # If the expectation is expect/expect_same use the severity in case of false result
        expectation_results
        |> Enum.map(&normalize_expectation_result(&1.result, severity))
        |> Enum.map(&{&1, result_weight(&1)})
        |> Enum.max_by(fn {_, weight} -> weight end)
        |> elem(0)
      end

    %CheckResult{check_result | result: result}
  end

  defp normalize_expectation_result(true, _), do: :passing
  defp normalize_expectation_result(false, severity), do: severity
  defp normalize_expectation_result(result, _), do: result

  defp errors?(agents_check_results),
    do:
      Enum.any?(agents_check_results, fn
        %AgentCheckError{} -> true
        _ -> false
      end)

  defp aggregate_execution_result(%Result{check_results: check_results} = execution) do
    result =
      check_results
      |> Enum.map(& &1.result)
      |> Enum.map(&{&1, result_weight(&1)})
      |> Enum.max_by(fn {_, weight} -> weight end)
      |> elem(0)

    %Result{execution | result: result}
  end

  # TODO: is unknown needed?
  # defp result_weight(:unknown), do: 3
  defp result_weight(:critical), do: 2
  defp result_weight(:warning), do: 1
  defp result_weight(:passing), do: 0
end

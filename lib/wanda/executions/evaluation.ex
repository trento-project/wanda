# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: Apache-2.0

defmodule Wanda.Executions.Evaluation do
  @moduledoc """
  Evaluation functional core.
  """

  alias Wanda.Catalog.{Check, Expectation, SelectedCheck}
  alias Wanda.Catalog.Evaluation, as: CatalogEvaluation

  alias Wanda.Executions.{
    AgentCheckError,
    AgentCheckResult,
    CheckResult,
    ExcludedCheckResult,
    ExpectationEvaluation,
    ExpectationEvaluationError,
    ExpectationResult,
    FactError,
    Result,
    Value
  }

  alias Wanda.EvaluationEngine

  require Wanda.Catalog.Enums.ExpectType, as: ExpectType
  require Wanda.Executions.Enums.AgentCheckStatus, as: AgentCheckStatus
  require Wanda.Executions.Enums.Result, as: ResultEnum

  @default_failure_message "Expectation not met"

  @spec execute(
          String.t(),
          String.t(),
          [SelectedCheck.t()],
          map(),
          %{String.t() => boolean() | number() | String.t()},
          [ExcludedCheckResult.t()],
          [String.t()],
          Rhai.Engine.t()
        ) :: Result.t()
  def execute(
        execution_id,
        group_id,
        checks,
        gathered_facts,
        env,
        excluded_checks,
        timeouts \\ [],
        engine
      ) do
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
    |> add_excluded_checks_result(excluded_checks, checks)
    |> aggregate_execution_result()
  end

  defp add_checks_result(%Result{} = result, checks, gathered_facts, env, engine) do
    check_results =
      Enum.map(gathered_facts, fn {check_id, agents_facts} ->
        %SelectedCheck{} = selected_check = Enum.find(checks, &(&1.id == check_id))

        build_check_result(selected_check, agents_facts, env, engine)
      end)

    %Result{result | check_results: check_results}
  end

  defp build_check_result(
         %SelectedCheck{
           id: check_id,
           spec: %Check{
             severity: severity,
             expectations: expectations
           },
           customized: customized
         } = selected_check,
         agents_facts,
         env,
         engine
       ) do
    %CheckResult{
      check_id: check_id,
      customized: customized
    }
    |> add_agents_results(
      selected_check,
      agents_facts,
      env,
      engine
    )
    |> add_expectation_results(expectations, engine)
    |> aggregate_check_result(severity)
  end

  defp add_agents_results(
         %CheckResult{} = check_result,
         %SelectedCheck{} = selected_check,
         agents_facts,
         env,
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
          add_agent_check_result_or_error(agent_id, selected_check, facts, env, engine)
      end)

    %CheckResult{check_result | agents_check_results: agents_results}
  end

  defp add_agent_check_result_or_error(agent_id, selected_check, facts, env, engine) do
    if has_some_fact_gathering_error?(facts) do
      %AgentCheckError{
        agent_id: agent_id,
        facts: facts,
        type: :fact_gathering_error,
        message: "Fact gathering error occurred during the execution"
      }
    else
      %SelectedCheck{
        spec: %Check{
          values: spec_values,
          expectations: expectations
        },
        customizations: customizations
      } = selected_check

      resolved_values =
        spec_values
        |> CatalogEvaluation.resolve_values(customizations, env, engine)
        |> Enum.map(&Value.from_resolved_value/1)

      expectation_evaluation_scope =
        %{}
        |> add_scope("facts", facts)
        |> add_scope("values", resolved_values)

      %AgentCheckResult{
        agent_id: agent_id,
        status: AgentCheckStatus.executed(),
        facts: facts,
        values: resolved_values,
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

  defp normalize_return_value(ExpectType.expect_enum(), "passing"), do: ResultEnum.passing()
  defp normalize_return_value(ExpectType.expect_enum(), "warning"), do: ResultEnum.warning()
  defp normalize_return_value(ExpectType.expect_enum(), _), do: ResultEnum.critical()
  defp normalize_return_value(_, return_value), do: return_value

  defp maybe_add_failure_message(
         %ExpectationEvaluation{type: ExpectType.expect(), return_value: false} =
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
         %ExpectationEvaluation{type: ExpectType.expect(), return_value: false} =
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
         %ExpectationEvaluation{
           type: ExpectType.expect_enum(),
           return_value: ResultEnum.critical()
         } =
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
         %ExpectationEvaluation{
           type: ExpectType.expect_enum(),
           return_value: ResultEnum.critical()
         } =
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
         %ExpectationEvaluation{
           type: ExpectType.expect_enum(),
           return_value: ResultEnum.warning()
         } =
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
         %ExpectationEvaluation{
           type: ExpectType.expect_enum(),
           return_value: ResultEnum.warning()
         } =
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
         %ExpectationResult{type: ExpectType.expect_same(), result: false} = expectation_result,
         nil,
         _warning_message,
         _evaluation_scope,
         _
       ),
       do: %ExpectationResult{expectation_result | failure_message: @default_failure_message}

  defp maybe_add_failure_message(
         %ExpectationResult{type: ExpectType.expect_same(), result: false} = expectation_result,
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

  defp eval_expectation_result(ExpectType.expect_same(), expectation_evaluations) do
    expectation_evaluations
    |> Enum.uniq_by(& &1.return_value)
    |> Kernel.length() == 1
  end

  defp eval_expectation_result(ExpectType.expect(), expectations_evaluations) do
    Enum.all?(expectations_evaluations, &(&1.return_value == true))
  end

  defp eval_expectation_result(ExpectType.expect_enum(), expectations_evaluations) do
    expectations_evaluations
    |> Enum.map(&{&1.return_value, result_weight(&1.return_value)})
    |> Enum.max_by(fn {_, weight} -> weight end)
    |> elem(0)
  end

  # Adds the excluded (check, agent) pairs into the corresponding check's
  # `agents_check_results` list, so the excluded host appears inline with the
  # other agent results rather than being silently dropped.
  #
  # A check that is excluded for *every* target is never requested for facts,
  # so `Evaluation.execute` produces no `CheckResult` for it. Such checks are
  # re-introduced here as passing results containing only excluded agents,
  # mirroring the `active_targets == []` branch of `handle_continue/2`. Without
  # this, a check excluded for all hosts while other checks still run would be
  # silently dropped from the final execution result.
  defp add_excluded_checks_result(%Result{} = result, [], _checks),
    do: result

  defp add_excluded_checks_result(
         %Result{check_results: check_results} = result,
         excluded,
         checks
       ) do
    excluded_by_check = Enum.group_by(excluded, & &1.check_id)
    existing_ids = MapSet.new(check_results, & &1.check_id)

    missing_check_results =
      checks
      |> Enum.filter(fn %SelectedCheck{spec: %Check{id: id}} ->
        Map.has_key?(excluded_by_check, id) and not MapSet.member?(existing_ids, id)
      end)
      |> Enum.map(fn %SelectedCheck{spec: %Check{id: id}, customized: customized} ->
        %CheckResult{
          check_id: id,
          customized: customized,
          agents_check_results: [],
          expectation_results: [],
          result: ResultEnum.passing()
        }
      end)

    new_check_results =
      Enum.map(check_results ++ missing_check_results, fn %CheckResult{check_id: check_id} =
                                                            check_result ->
        add_excluded_agents_result(check_result, Map.get(excluded_by_check, check_id))
      end)

    %Result{result | check_results: new_check_results}
  end

  defp add_excluded_agents_result(check_result, nil), do: check_result

  defp add_excluded_agents_result(%CheckResult{} = check_result, entries) do
    excluded_agents =
      Enum.map(entries, fn %ExcludedCheckResult{
                             agent_id: agent_id,
                             exclude_expression: exclude_expression
                           } ->
        %AgentCheckResult{
          agent_id: agent_id,
          status: AgentCheckStatus.excluded(),
          exclude_expression: exclude_expression
        }
      end)

    %CheckResult{
      check_result
      | agents_check_results: check_result.agents_check_results ++ excluded_agents
    }
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
          %AgentCheckError{type: :timeout} -> ResultEnum.critical()
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

  defp normalize_expectation_result(true, _), do: ResultEnum.passing()
  defp normalize_expectation_result(false, severity), do: severity
  defp normalize_expectation_result(result, _), do: result

  defp errors?(agents_check_results),
    do:
      Enum.any?(agents_check_results, fn
        %AgentCheckError{} -> true
        _ -> false
      end)

  defp aggregate_execution_result(%Result{check_results: []} = execution) do
    %Result{execution | result: ResultEnum.passing()}
  end

  defp aggregate_execution_result(%Result{check_results: check_results} = execution) do
    result =
      check_results
      |> Enum.map(& &1.result)
      |> Enum.map(&{&1, result_weight(&1)})
      |> Enum.max_by(fn {_, weight} -> weight end)
      |> elem(0)

    %Result{execution | result: result}
  end

  defp result_weight(ResultEnum.critical()), do: 2
  defp result_weight(ResultEnum.warning()), do: 1
  defp result_weight(ResultEnum.passing()), do: 0
end

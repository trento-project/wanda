defmodule Wanda.Execution.Expectations do
  @moduledoc """
  Expectations functional core.
  """

  alias Wanda.Catalog

  alias Wanda.Execution.{
    CheckResult,
    ExpectationResult,
    GroupExpectationResult,
    Result
  }

  # Abacus spec is wrong
  @dialyzer {:nowarn_function, eval_expectation: 2}

  @doc """
  Returns the results of checks expectations by agent.
  """
  @spec eval(map()) :: [Result.t()]
  def eval(gathered_facts) do
    {results, group_results_map} =
      Enum.map_reduce(gathered_facts, %{}, fn {agent_id, checks}, acc ->
        {checks_results, group_results_map} = build_checks_results(checks, acc)

        {%Result{
           agent_id: agent_id,
           checks_results: checks_results
         }, group_results_map}
      end)

    results
  end

  defp build_checks_results(checks, group_results_map) do
    Enum.map_reduce(checks, group_results_map, fn {check_id, facts}, acc ->
      expectations_results = eval_expectations(check_id, facts)

      group_expectations_results =
        Enum.filter(expectations_results, fn
          %GroupExpectationResult{} ->
            true

          _ ->
            false
        end)

      group_results_map =
        Enum.reduce(group_expectations_results, acc, fn %GroupExpectationResult{
                                                          name: name
                                                        } = result,
                                                        acc ->
          update_in(acc, [Access.key(check_id, %{}), name], fn
            nil ->
              [result]

            current_value ->
              [result | current_value]
          end)
        end)

      {%CheckResult{
         facts: facts,
         check_id: check_id,
         expectations_results: expectations_results,
         result: passed?(expectations_results)
       }, group_results_map}
    end)
  end

  defp eval_expectations(check_id, facts) do
    check_id
    |> Catalog.get_expectations()
    |> Enum.map(&eval_expectation(&1, facts))
  end

  defp eval_expectation(%{"name" => name, "group_expect_all" => expect}, facts) do
    case Abacus.eval(expect, facts) do
      {:ok, result} ->
        %GroupExpectationResult{name: name, type: :all, local_result: result}

      {:error, :einkey} ->
        %GroupExpectationResult{name: name, type: :all, local_result: :fact_missing_error}

      _ ->
        %GroupExpectationResult{name: name, type: :all, local_result: :illegal_expression_error}
    end
  end

  defp eval_expectation(%{"name" => name, "expect" => expect}, facts) do
    case Abacus.eval(expect, facts) do
      {:ok, result} ->
        %ExpectationResult{name: name, result: result}

      {:error, :einkey} ->
        %ExpectationResult{name: name, result: :fact_missing_error}

      _ ->
        %ExpectationResult{name: name, result: :illegal_expression_error}
    end
  end

  # TODO: read catalog to get check severity
  defp passed?(expectations_results) do
    if Enum.all?(expectations_results, &(&1.result == true)) do
      :passing
    else
      :critical
    end
  end
end

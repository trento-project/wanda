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
      Enum.map_reduce(gathered_facts, [], fn {agent_id, checks}, acc ->
        {checks_results, group_results_map} = build_checks_results(checks, acc)

        {%Result{
           agent_id: agent_id,
           checks_results: checks_results
         }, group_results_map}
      end)

    grouped_stuff =
      Enum.group_by(
        group_results_map,
        fn el -> {el.check_id, el.expectation, el.type} end,
        fn el -> el.result end
      )

    grouped_stuff_computed =
      Enum.into(grouped_stuff, %{}, fn {{check, name, type}, v} ->
        {{check, name}, compute_group(type, v)}
      end)

    compute_final_results(results, grouped_stuff_computed) |> IO.inspect()
  end

  defp compute_group(:all, results) do
    Enum.all?(results, &(&1.local_result == true))
  end

  defp compute_final_results(results, grouped_stuff_computed) do
    Enum.map(results, fn result ->
      %Result{
        result
        | checks_results:
            Enum.map(result.checks_results, fn cr ->
              expectations_results =
                Enum.map(cr.expectations_results, fn %GroupExpectationResult{name: name} = gr ->
                  Map.put(gr, :result, Map.get(grouped_stuff_computed, {cr.check_id, name}))
                end)

              %CheckResult{
                cr
                | expectations_results: expectations_results,
                  result: passed?(expectations_results)
              }
            end)
      }
    end)
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

      new_stuff =
        Enum.map(
          group_expectations_results,
          fn %GroupExpectationResult{} = g ->
            %{
              type: g.type,
              result: g,
              check_id: check_id,
              expectation: g.name
            }
          end
        )

      {%CheckResult{
         facts: facts,
         check_id: check_id,
         expectations_results: expectations_results
       }, acc ++ new_stuff}
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

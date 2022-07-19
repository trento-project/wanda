defmodule Wanda.Execution.Expectations do
  @moduledoc """
  Expectations functional core.
  """

  alias Wanda.Catalog

  alias Wanda.Execution.{
    CheckResult,
    ExpectationResult,
    Result
  }

  # Abacus spec is wrong
  @dialyzer {:nowarn_function, eval_expectation: 2}

  @doc """
  Returns the results of checks expectations by agent.
  """
  @spec eval(map()) :: [Result.t()]
  def eval(gathered_facts) do
    Enum.map(gathered_facts, fn {agent_id, checks} ->
      %Result{
        agent_id: agent_id,
        checks_results: eval_expectations(checks)
      }
    end)
  end

  defp eval_expectations(checks) do
    Enum.map(checks, fn {check_id, facts} ->
      expectations_results = eval_expectations(check_id, facts)

      %CheckResult{
        facts: facts,
        check_id: check_id,
        expectations_results: expectations_results,
        result: passed?(expectations_results)
      }
    end)
  end

  defp eval_expectations(check_id, facts) do
    check_id
    |> Catalog.get_expectations()
    |> Enum.map(&eval_expectation(&1, facts))
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

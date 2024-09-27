defmodule WandaWeb.V1.ExecutionJSON do
  alias Wanda.Executions.Execution
  alias WandaWeb.V1.ExecutionJSON

  def index(%{executions: executions, total_count: total_count}) do
    %{
      items: Enum.map(executions, &execution/1),
      total_count: total_count
    }
  end

  def execution(%Execution{} = execution) do
    execution
    |> WandaWeb.V2.ExecutionJSON.execution()
    |> adapt_v1()
  end

  def show(%{execution: execution}) do
    ExecutionJSON.execution(execution)
  end

  def start(%{
        accepted_execution: %{
          execution_id: execution_id,
          group_id: group_id
        }
      }) do
    %{
      execution_id: execution_id,
      group_id: group_id
    }
  end

  defp adapt_v1(%{check_results: nil} = execution), do: execution

  defp adapt_v1(%{check_results: check_results} = execution) do
    %{execution | check_results: Enum.map(check_results, &adapt_v1_check_results/1)}
  end

  defp adapt_v1_check_results(
         %{
           "agents_check_results" => agents_check_results,
           "expectation_results" => expectation_results
         } = check_result
       ) do
    adapted_agents_check_results =
      Enum.map(
        agents_check_results,
        &adapt_v1_agent_check_results(&1)
      )

    adapted_expectation_results = update_expect_enum(expectation_results)

    %{
      check_result
      | "agents_check_results" => adapted_agents_check_results,
        "expectation_results" => adapted_expectation_results
    }
  end

  defp adapt_v1_agent_check_results(
         %{"expectation_evaluations" => expectation_evaluations} = agent_check_results
       ) do
    %{
      agent_check_results
      | "expectation_evaluations" => update_expect_enum(expectation_evaluations)
    }
  end

  defp adapt_v1_agent_check_results(agent_check_results), do: agent_check_results

  defp update_expect_enum(expectations) do
    Enum.map(expectations, fn
      %{"type" => "expect_enum"} = expectation -> Map.put(expectation, "type", "unknown")
      expectation -> expectation
    end)
  end
end

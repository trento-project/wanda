defmodule WandaWeb.V1.ExecutionView do
  use WandaWeb, :view

  alias WandaWeb.V1.ExecutionView

  def render("index.json", %{executions: executions, total_count: total_count}) do
    %{
      items: render_many(executions, ExecutionView, "execution.json"),
      total_count: total_count
    }
  end

  def render("show.json", %{execution: execution}) do
    render_one(execution, ExecutionView, "execution.json")
  end

  def render("execution.json", %{execution: execution}) do
    execution
    |> render_one(WandaWeb.V2.ExecutionView, "execution.json")
    |> adapt_v1()
  end

  def render("start.json", %{
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

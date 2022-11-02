defmodule WandaWeb.ExecutionView do
  use WandaWeb, :view

  alias Wanda.Executions.Execution
  alias WandaWeb.ExecutionView

  def render("index.json", %{executions: executions, total_count: total_count}) do
    %{
      items: render_many(executions, ExecutionView, "execution.json"),
      total_count: total_count
    }
  end

  def render("show.json", %{execution: execution}) do
    render_one(execution, ExecutionView, "execution.json")
  end

  def render("execution.json", %{
        execution: %ExecutionResult{
          execution_id: execution_id,
          group_id: group_id,
          status: status,
          result: result,
          started_at: started_at,
          completed_at: completed_at
        }
      }) do
    %{
      check_results: extract_checks_results(status, result),
      status: status,
      started_at: started_at,
      completed_at: completed_at,
      execution_id: execution_id,
      group_id: group_id,
      result: extract_result(status, result),
      timeout: extract_timeout(status, result)
    }
  end

  defp extract_result(:running, _), do: :unknown
  defp extract_result(:completed, %{"result" => result}), do: result

  defp extract_timeout(:running, _), do: []
  defp extract_timeout(:completed, %{"timeout" => timeout}), do: timeout

  defp extract_checks_results(:running, _), do: []
  defp extract_checks_results(:completed, %{"check_results" => check_results}), do: check_results
end

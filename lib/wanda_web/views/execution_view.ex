defmodule WandaWeb.ExecutionView do
  use WandaWeb, :view

  alias WandaWeb.ExecutionView

  alias Wanda.Executions.Execution

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
        execution: %Execution{
          execution_id: execution_id,
          group_id: group_id,
          status: status,
          result: result,
          started_at: started_at,
          completed_at: completed_at
        }
      }) do
    %{
      check_results: map_checks_results(status, result),
      status: status,
      started_at: started_at,
      completed_at: completed_at,
      execution_id: execution_id,
      group_id: group_id,
      result: map_result(status, result),
      timeout: map_timeout(status, result)
    }
  end

  defp map_result(:running, _), do: nil
  defp map_result(:completed, %{"result" => result}), do: result

  defp map_timeout(:running, _), do: nil
  defp map_timeout(:completed, %{"timeout" => timeout}), do: timeout

  defp map_checks_results(:running, _), do: nil
  defp map_checks_results(:completed, %{"check_results" => check_results}), do: check_results
end

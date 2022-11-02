defmodule WandaWeb.ExecutionView do
  use WandaWeb, :view

  alias Wanda.Executions.Execution
  alias WandaWeb.ExecutionView

  def render("index.json", %{results: results, total_count: total_count}) do
    %{
      items: render_many(results, ExecutionView, "execution.json"),
      total_count: total_count
    }
  end

  def render("show.json", %{result: result}) do
    render_one(result, ExecutionView, "execution.json")
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
    result
    |> Map.put("check_results", extract_checks_results(status, result))
    |> Map.put("status", status)
    |> Map.put("started_at", started_at)
    |> Map.put("completed_at", completed_at)
    |> Map.put("execution_id", execution_id)
    |> Map.put("group_id", group_id)
    |> Map.put("result", extract_result(status, result))
    |> Map.put("timeout", extract_timeout(status, result))
  end

  defp extract_result(:running, _), do: :unknown

  defp extract_result(:completed, %{result: result} = execution) when is_struct(execution),
    do: result

  defp extract_result(:completed, %{"result" => result} = execution) when is_map(execution),
    do: result

  defp extract_timeout(:running, _), do: []

  defp extract_timeout(:completed, %{timeout: timeout} = execution) when is_struct(execution),
    do: timeout

  defp extract_timeout(:completed, %{"timeout" => timeout} = execution) when is_map(execution),
    do: timeout

  defp extract_checks_results(:running, _), do: []

  defp extract_checks_results(:completed, %{check_results: check_results} = execution)
       when is_struct(execution),
       do: check_results

  defp extract_checks_results(:completed, %{"check_results" => check_results} = execution)
       when is_map(execution),
       do: check_results
end

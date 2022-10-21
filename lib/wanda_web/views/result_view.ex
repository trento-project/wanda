defmodule WandaWeb.ResultView do
  use WandaWeb, :view

  alias Wanda.Results.ExecutionResult
  alias WandaWeb.ResultView

  def render("index.json", %{results: results, total_count: total_count}) do
    %{
      items: render_many(results, ResultView, "result.json"),
      total_count: total_count
    }
  end

  def render("show.json", %{result: result}) do
    render_one(result, ResultView, "result.json")
  end

  def render("result.json", %{
        result: %ExecutionResult{
          execution_id: execution_id,
          group_id: group_id,
          status: status,
          payload: result,
          started_at: started_at
        }
      }) do
    result
    |> Map.put("started_at", started_at)
    |> Map.put("execution_id", execution_id)
    |> Map.put("group_id", group_id)
    |> Map.put("result", extract_result(status, result))
    |> Map.put("timeout", extract_timeout(status, result))
  end

  # not really
  defp extract_result(:running, _), do: :passing
  defp extract_result(:completed, %{result: result}), do: result

  defp extract_timeout(:running, _), do: []
  defp extract_timeout(:completed, %{timeout: timeout}), do: timeout
end

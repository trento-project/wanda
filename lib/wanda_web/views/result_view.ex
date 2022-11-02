defmodule WandaWeb.ResultView do
  use WandaWeb, :view

  alias Wanda.Executions.Execution
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
        result: %Execution{
          execution_id: execution_id,
          group_id: group_id,
          status: status,
          result: result,
          started_at: started_at
        }
      }) do
    # FIXME: this is just to keep tests passing as of now
    # we will shortly refactor the API layer to properly consider the execution status running/compelted
    # and the shaper it can have when in different statuses
    result
    |> Map.put("started_at", started_at)
    |> Map.put("execution_id", execution_id)
    |> Map.put("group_id", group_id)
    |> Map.put("result", extract_result(status, result))
    |> Map.put("timeout", extract_timeout(status, result))
  end

  defp extract_result(:running, _), do: :passing
  defp extract_result(:completed, %{result: result}), do: result

  defp extract_timeout(:running, _), do: []
  defp extract_timeout(:completed, %{timeout: timeout}), do: timeout
end

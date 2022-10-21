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

  def render("result.json", %{result: %ExecutionResult{payload: result, started_at: started_at}}) do
    Map.put(result, "started_at", started_at)
  end
end

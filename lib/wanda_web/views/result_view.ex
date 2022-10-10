defmodule WandaWeb.ResultView do
  use WandaWeb, :view

  alias Wanda.Results.ExecutionResult

  def render("list_results.json", %{results: results, total_count: total_count}) do
    %{
      items: render_many(results, WandaWeb.ResultView, "result.json", as: :result),
      total_count: total_count
    }
  end

  def render("result.json", %{result: %ExecutionResult{payload: result, inserted_at: inserted_at}}) do
    Map.put(result, "inserted_at", inserted_at)
  end
end

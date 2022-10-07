defmodule WandaWeb.ResultView do
  use WandaWeb, :view

  alias Wanda.Results.ExecutionResult

  def render("list_results.json", %{results: results, total_count: total_count}) do
    %{
      items: render_many(results, WandaWeb.ResultView, "result.json", as: :result),
      total_count: total_count
    }
  end

  def render("result.json", %{result: %ExecutionResult{} = result}) do
    result
  end
end

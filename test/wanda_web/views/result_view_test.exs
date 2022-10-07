defmodule WandaWeb.ListResultsViewTest do
  use WandaWeb.ConnCase, async: true

  import Phoenix.View
  import Wanda.Factory

  describe "ResultView" do
    test "renders list_results.json" do
      results = build_list(3, :execution_result)

      assert %{
               items: ^results,
               total_count: 10
             } =
               render(WandaWeb.ResultView, "list_results.json",
                 results: results,
                 total_count: 10
               )
    end
  end
end

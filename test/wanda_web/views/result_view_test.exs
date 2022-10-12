defmodule WandaWeb.ListResultsViewTest do
  use WandaWeb.ConnCase, async: true

  import Phoenix.View
  import Wanda.Factory

  alias Wanda.Results.ExecutionResult

  describe "ResultView" do
    test "renders list_results.json" do
      inserted_at = DateTime.utc_now()

      [
        %ExecutionResult{execution_id: execution_id_1, group_id: group_id_1},
        %ExecutionResult{execution_id: execution_id_2, group_id: group_id_2}
      ] =
        execution_results =
        Enum.map(1..2, fn _ ->
          :execution_result
          |> build(inserted_at: inserted_at)
          |> insert(returning: true)
        end)

      assert %{
               items: [
                 %{
                   "execution_id" => ^execution_id_1,
                   "group_id" => ^group_id_1,
                   "inserted_at" => ^inserted_at
                 },
                 %{
                   "execution_id" => ^execution_id_2,
                   "group_id" => ^group_id_2,
                   "inserted_at" => ^inserted_at
                 }
               ],
               total_count: 10
             } =
               render(WandaWeb.ResultView, "list_results.json",
                 results: execution_results,
                 total_count: 10
               )
    end
  end
end

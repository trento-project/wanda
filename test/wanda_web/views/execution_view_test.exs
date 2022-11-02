defmodule WandaWeb.ListExecutionsViewTest do
  use WandaWeb.ConnCase, async: true

  import Phoenix.View
  import Wanda.Factory

  alias Wanda.Results.ExecutionResult

  describe "ExecutionView" do
    test "renders index.json" do
      started_at = DateTime.utc_now()

      [
        %ExecutionResult{execution_id: execution_id_1, group_id: group_id_1},
        %ExecutionResult{execution_id: execution_id_2, group_id: group_id_2}
      ] =
        execution_results =
        Enum.map(1..2, fn _ ->
          :execution_result
          |> build(started_at: started_at)
          |> insert(returning: true)
        end)

      assert %{
               items: [
                 %{
                   "execution_id" => ^execution_id_1,
                   "group_id" => ^group_id_1,
                   "started_at" => ^started_at
                 },
                 %{
                   "execution_id" => ^execution_id_2,
                   "group_id" => ^group_id_2,
                   "started_at" => ^started_at
                 }
               ],
               total_count: 10
             } =
               render(WandaWeb.ExecutionView, "index.json",
                 results: execution_results,
                 total_count: 10
               )
    end

    test "renders show.json" do
      started_at = DateTime.utc_now()

      %ExecutionResult{execution_id: execution_id, group_id: group_id} =
        execution_result =
        :execution_result
        |> build(started_at: started_at)
        |> insert(returning: true)

      assert %{
               "execution_id" => ^execution_id,
               "group_id" => ^group_id,
               "started_at" => ^started_at
             } = render(WandaWeb.ExecutionView, "show.json", result: execution_result)
    end
  end
end

defmodule WandaWeb.ExecutionViewTest do
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
        executions =
        Enum.map(1..2, fn _ ->
          :execution_result
          |> build(started_at: started_at)
          |> insert(returning: true)
        end)

      assert %{
               items: [
                 %{
                   execution_id: ^execution_id_1,
                   group_id: ^group_id_1,
                   started_at: ^started_at
                 },
                 %{
                   execution_id: ^execution_id_2,
                   group_id: ^group_id_2,
                   started_at: ^started_at
                 }
               ],
               total_count: 10
             } =
               render(WandaWeb.ExecutionView, "index.json",
                 executions: executions,
                 total_count: 10
               )
    end

    test "renders show.json for a running execution" do
      started_at = DateTime.utc_now()

      %ExecutionResult{execution_id: execution_id, group_id: group_id} =
        execution =
        :execution_result
        |> build(started_at: started_at)
        |> insert(returning: true)

      assert %{
               execution_id: ^execution_id,
               group_id: ^group_id,
               started_at: ^started_at,
               completed_at: nil,
               status: :running,
               timeout: nil,
               check_results: nil
             } = render(WandaWeb.ExecutionView, "show.json", execution: execution)
    end

    test "renders show.json for a completed execution" do
      started_at = DateTime.utc_now()

      %ExecutionResult{
        execution_id: execution_id,
        group_id: group_id,
        completed_at: completed_at,
        payload: %{
          "timeout" => timeout,
          "check_results" => check_results
        }
      } =
        execution =
        :execution_result
        |> build(started_at: started_at)
        |> with_completed_status()
        |> insert(returning: true)

      assert %{
               execution_id: ^execution_id,
               group_id: ^group_id,
               started_at: ^started_at,
               completed_at: ^completed_at,
               status: :completed,
               timeout: ^timeout,
               check_results: ^check_results
             } = render(WandaWeb.ExecutionView, "show.json", execution: execution)
    end
  end
end

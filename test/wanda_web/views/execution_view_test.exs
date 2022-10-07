defmodule WandaWeb.ExecutionViewTest do
  use WandaWeb.ConnCase, async: true

  import Phoenix.View
  import Wanda.Factory

  alias Wanda.Results.ExecutionResult

  describe "ExecutionView" do
    test "renders list_checks_executions.json" do
      [
        %ExecutionResult{execution_id: execution_1, group_id: group_1},
        %ExecutionResult{execution_id: execution_2, group_id: group_2},
        %ExecutionResult{execution_id: execution_3, group_id: group_3}
      ] = data = build_list(3, :execution_result)

      assert %{
               data: [
                 %ExecutionResult{execution_id: ^execution_1, group_id: ^group_1},
                 %ExecutionResult{execution_id: ^execution_2, group_id: ^group_2},
                 %ExecutionResult{execution_id: ^execution_3, group_id: ^group_3}
               ],
               total_count: 3
             } =
               render(WandaWeb.ExecutionView, "list_checks_executions.json",
                 data: data,
                 total_count: length(data)
               )
    end
  end
end

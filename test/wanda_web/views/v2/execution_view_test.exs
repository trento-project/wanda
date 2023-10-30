defmodule WandaWeb.V2.ExecutionViewTest do
  use WandaWeb.ConnCase, async: true

  alias WandaWeb.V2.ExecutionView

  describe "ExecutionView" do
    test "renders start.json with a payload" do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()

      assert %{execution_id: execution_id, group_id: group_id} ==
               ExecutionView.render("start.json", %{
                 accepted_execution: %{execution_id: execution_id, group_id: group_id}
               })
    end
  end
end

defmodule WandaWeb.V2.ExecutionView do
  use WandaWeb, :view

  def render("start.json", %{
        accepted_execution: %{
          execution_id: execution_id,
          group_id: group_id
        }
      }) do
    %{
      execution_id: execution_id,
      group_id: group_id
    }
  end
end

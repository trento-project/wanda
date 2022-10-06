defmodule WandaWeb.ExecutionsView do
  use WandaWeb, :view

  def render("list_checks_executions.json", %{data: data, total_count: total_count}) do
    %{data: data, total_count: total_count}
  end
end

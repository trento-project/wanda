defmodule WandaWeb.ExecutionView do
  use WandaWeb, :view

  alias Wanda.Results.ExecutionResult

  def render("list_checks_executions.json", %{data: data, total_count: total_count}) do
    %{
      data:
        render_many(data, WandaWeb.ExecutionView, "execution_result.json", as: :execution_result),
      total_count: total_count
    }
  end

  def render("execution_result.json", %{execution_result: %ExecutionResult{} = execution_result}) do
    execution_result
  end
end

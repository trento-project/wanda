defmodule WandaWeb.Schemas.CheckExecutionResponse do
  @moduledoc """
  Check execution response API spec
  """

  require OpenApiSpex

  alias OpenApiSpex.Schema
  alias WandaWeb.Schemas.CheckExecution

  OpenApiSpex.schema(%{
    title: "CheckExecutionResponse",
    description: "Check execution listing response",
    type: :object,
    properties: %{
      data: %Schema{type: :array, description: "", items: CheckExecution},
      total_count: %Schema{type: :integer, description: ""}
    }
  })
end

defmodule WandaWeb.Schemas.ListExecutionsResponse do
  @moduledoc """
  Execution list response API spec
  """

  alias OpenApiSpex.Schema

  alias WandaWeb.Schemas.ExecutionResponse

  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "ListExecutionsResponse",
    description: "The paginated list of executions",
    type: :object,
    properties: %{
      items: %Schema{type: :array, items: ExecutionResponse},
      total_count: %Schema{type: :integer, description: "Total count of executions"}
    }
  })
end

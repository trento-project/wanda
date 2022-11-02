defmodule WandaWeb.Schemas.ListExecutionsResponse do
  @moduledoc nil

  require OpenApiSpex

  alias OpenApiSpex.Schema

  alias WandaWeb.Schemas.ExecutionResponse

  OpenApiSpex.schema(%{
    title: "ListExecutionsResponse",
    description: "The paginated list of results",
    type: :object,
    properties: %{
      items: %Schema{type: :array, items: ExecutionResponse},
      total_count: %Schema{type: :integer, description: "Total count of results"}
    }
  })
end

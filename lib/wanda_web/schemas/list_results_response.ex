defmodule WandaWeb.Schemas.ListResultsResponse do
  @moduledoc """
  Check execution response API spec
  """

  require OpenApiSpex

  alias OpenApiSpex.Schema
  alias WandaWeb.Schemas.Result

  OpenApiSpex.schema(%{
    title: "ListResultsResponse",
    description: "The paginated list of results.",
    type: :object,
    properties: %{
      items: %Schema{type: :array, items: Result},
      total_count: %Schema{type: :integer, description: "Total count of results."}
    }
  })
end

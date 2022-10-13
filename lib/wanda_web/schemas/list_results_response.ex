defmodule WandaWeb.Schemas.ListResultsResponse do
  @moduledoc nil

  require OpenApiSpex

  alias OpenApiSpex.Schema

  alias WandaWeb.Schemas.ResultResponse

  OpenApiSpex.schema(%{
    title: "ListResultsResponse",
    description: "The paginated list of results",
    type: :object,
    properties: %{
      items: %Schema{type: :array, items: ResultResponse},
      total_count: %Schema{type: :integer, description: "Total count of results"}
    }
  })
end

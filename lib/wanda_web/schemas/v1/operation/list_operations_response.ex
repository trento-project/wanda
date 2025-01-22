defmodule WandaWeb.Schemas.V1.Operation.ListOperationsResponse do
  @moduledoc """
  Operation list response API spec
  """

  alias OpenApiSpex.Schema

  alias WandaWeb.Schemas.V1.Operation.OperationResponse

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "ListOperationsResponse",
      description: "The paginated list of operations",
      type: :object,
      additionalProperties: false,
      properties: %{
        items: %Schema{type: :array, items: OperationResponse},
        total_count: %Schema{type: :integer, description: "Total count of operations"}
      }
    },
    struct?: false
  )
end

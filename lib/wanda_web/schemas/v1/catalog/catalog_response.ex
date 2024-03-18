defmodule WandaWeb.Schemas.V1.Catalog.CatalogResponse do
  @moduledoc """
  Checks catalog response API spec
  """

  alias OpenApiSpex.Schema
  alias WandaWeb.Schemas.V1.Catalog.Check

  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "CatalogResponse",
    description: "Checks catalog listing response",
    type: :object,
    additionalProperties: false,
    properties: %{
      items: %Schema{type: :array, description: "List of catalog checks", items: Check}
    }
  })
end

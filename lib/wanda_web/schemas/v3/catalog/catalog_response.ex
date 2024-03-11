defmodule WandaWeb.Schemas.V3.Catalog.CatalogResponse do
  @moduledoc """
  Checks catalog response API spec
  """

  alias OpenApiSpex.Schema
  alias WandaWeb.Schemas.V3.Catalog.Check

  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "CatalogResponse",
    description: "Checks catalog listing response",
    additionalProperties: false,
    type: :object,


    properties: %{
      items: %Schema{type: :array, description: "List of catalog checks", items: Check}
    }
  })
end

defmodule WandaWeb.Schemas.CatalogResponse do
  @moduledoc """
  Checks catalog response API spec
  """

  require OpenApiSpex

  alias OpenApiSpex.Schema
  alias WandaWeb.Schemas.CatalogCheck

  OpenApiSpex.schema(%{
    title: "CatalogResponse",
    description: "Checks catalog listing response",
    type: :object,
    properties: %{
      items: %Schema{type: :array, description: "List of catalog checks", items: CatalogCheck}
    }
  })
end

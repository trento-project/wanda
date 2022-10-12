defmodule WandaWeb.CatalogController do
  use WandaWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Wanda.Catalog
  alias WandaWeb.Schemas.CatalogResponse

  operation :catalog,
    summary: "List checks catalog",
    responses: [
      ok: {"Check catalog response", "application/json", CatalogResponse}
    ]

  def catalog(conn, _) do
    catalog = Catalog.get_catalog()
    render(conn, catalog: catalog)
  end
end

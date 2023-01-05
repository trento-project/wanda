defmodule WandaWeb.CatalogController do
  use WandaWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Wanda.Catalog
  alias WandaWeb.Schemas.CatalogResponse

  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true

  operation :catalog,
    summary: "List checks catalog",
    parameters: [
      provider: [in: :query, type: :string, description: "cloud provider"]
    ],
    responses: [
      ok: {"Check catalog response", "application/json", CatalogResponse}
    ]

  def catalog(conn, params) do
    catalog = Catalog.get_catalog(params)
    render(conn, catalog: catalog)
  end
end

defmodule WandaWeb.V1.CatalogController do
  use WandaWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Wanda.Catalog
  alias WandaWeb.Schemas.CatalogResponse
  alias WandaWeb.Schemas.Env

  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true

  operation :catalog,
    summary: "List checks catalog",
    parameters: [
      env: [
        in: :query,
        description: "env variables",
        explode: true,
        style: :form,
        schema: Env
      ]
    ],
    responses: [
      ok: {"Check catalog response", "application/json", CatalogResponse}
    ]

  def catalog(conn, params) do
    catalog = Catalog.get_catalog(params)
    render(conn, catalog: catalog)
  end
end

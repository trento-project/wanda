defmodule WandaWeb.V3.CatalogController do
  use WandaWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Wanda.Catalog
  alias WandaWeb.Schemas.V2.Env
  alias WandaWeb.Schemas.V3.Catalog.CatalogResponse

  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true

  operation :catalog,
    summary: "List checks catalog",
    tags: ["Wanda checks"],
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
      ok: {"Check catalog response", "application/json", CatalogResponse},
      unprocessable_entity: OpenApiSpex.JsonErrorResponse.response()
    ]

  def catalog(conn, params) do
    catalog = Catalog.get_catalog(params)
    render(conn, catalog: catalog)
  end
end

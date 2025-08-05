defmodule WandaWeb.V2.CatalogController do
  use WandaWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Wanda.Catalog
  alias WandaWeb.Schemas.V1.Catalog.CatalogResponse
  alias WandaWeb.Schemas.V2.Env

  alias WandaWeb.Schemas.UnprocessableEntity

  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true

  operation :catalog,
    summary: "List checks catalog",
    tags: ["Wanda Checks"],
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
      unprocessable_entity: UnprocessableEntity.response()
    ]

  def catalog(conn, params) do
    catalog = Catalog.get_catalog(params)
    render(conn, catalog: catalog)
  end
end

defmodule WandaWeb.V2.CatalogController do
  use WandaWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Wanda.Catalog
  alias WandaWeb.Schemas.V1.Catalog.CatalogResponse
  alias WandaWeb.Schemas.V2.Env

  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true

  operation :catalog,
    summary: "List checks catalog.",
    description:
      "Provides the catalog of checks that can be executed in the system for improved reliability and compliance.",
    tags: ["Wanda Checks"],
    parameters: [
      env: [
        in: :query,
        description:
          "Specify environment variables to filter or customize the returned catalog of checks.",
        explode: true,
        style: :form,
        schema: Env
      ]
    ],
    responses: [
      ok:
        {"A successful response containing the catalog of available checks.", "application/json",
         CatalogResponse},
      unprocessable_entity: OpenApiSpex.JsonErrorResponse.response()
    ]

  def catalog(conn, params) do
    catalog = Catalog.get_catalog(params)
    render(conn, catalog: catalog)
  end
end

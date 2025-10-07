defmodule WandaWeb.V1.CatalogController do
  use WandaWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias OpenApiSpex.Schema

  alias Wanda.Catalog
  alias WandaWeb.Schemas.V1.Catalog.CatalogResponse

  alias WandaWeb.Schemas.V1.{
    Env,
    UnprocessableEntity
  }

  alias WandaWeb.Schemas.V1.ChecksSelection.SelectableChecksResponse
  alias WandaWeb.Schemas.V2.Env, as: V2Env

  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true

  operation :catalog,
    summary: "List checks catalog.",
    deprecated: true,
    description:
      "Provides the catalog of checks that can be executed in the system for improved reliability and compliance.",
    tags: ["Checks Engine"],
    parameters: [
      env: [
        in: :query,
        description:
          "Specify environment variables to filter or customize the returned catalog of checks.",
        explode: true,
        style: :form,
        schema: Env,
        example: %{"SOME_ENV" => "value"}
      ]
    ],
    responses: [
      ok:
        {"A successful response containing the catalog of available checks.", "application/json",
         CatalogResponse},
      unprocessable_entity: UnprocessableEntity.response()
    ]

  def catalog(conn, params) do
    catalog = Catalog.get_catalog(params)
    render(conn, catalog: catalog)
  end

  operation :selectable_checks,
    summary: "List selectable checks for a given execution group and environment.",
    description:
      "Provides a list of selectable checks for a specified group and environment, enabling targeted execution.",
    tags: ["Checks Engine"],
    parameters: [
      group_id: [
        in: :path,
        description:
          "The unique identifier of the group for which selectable checks are to be listed.",
        type: %Schema{
          type: :string,
          format: :uuid
        },
        example: "c1a2b3c4-d5e6-7890-abcd-ef1234567890"
      ],
      env: [
        in: :query,
        description:
          "Specify environment variables to filter or customize the selectable checks returned.",
        explode: true,
        style: :form,
        schema: V2Env
      ]
    ],
    responses: [
      ok:
        {"A successful response containing the selectable checks for the specified group and environment.",
         "application/json", SelectableChecksResponse}
    ]

  def selectable_checks(conn, params) do
    {group_id, updated_params} = Map.pop(params, :group_id)

    render(conn, %{
      selectable_checks: Catalog.get_catalog_for_group(group_id, updated_params)
    })
  end
end

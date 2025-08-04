defmodule WandaWeb.V1.CatalogController do
  use WandaWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias OpenApiSpex.Schema

  alias Wanda.Catalog
  alias WandaWeb.Schemas.V1.Catalog.CatalogResponse
  alias WandaWeb.Schemas.V1.Env

  alias WandaWeb.Schemas.V1.ChecksSelection.SelectableChecksResponse
  alias WandaWeb.Schemas.V2.Env, as: V2Env

  alias WandaWeb.Schemas.UnprocessableEntity

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
        schema: Env,
        example: %{"SOME_ENV" => "value"}
      ]
    ],
    responses: [
      ok: {
        "Check catalog response",
        "application/json",
        CatalogResponse,
        example: %{
          items: [
            %{
              id: "SLES-HA-1",
              name: "Cluster node fencing configured",
              group: "SLES-HA",
              description: "Checks if fencing is configured for all cluster nodes.",
              remediation: "Configure fencing for all cluster nodes to ensure high availability.",
              metadata: %{"category" => "ha", "impact" => "critical"},
              severity: "critical",
              facts: [
                %{name: "node_count", gatherer: "cluster_node_gatherer", argument: ""}
              ],
              values: [
                %{
                  name: "fencing_configured",
                  default: false,
                  conditions: [
                    %{value: true, expression: "node_count > 1"}
                  ]
                }
              ],
              expectations: [
                %{
                  name: "fencing_enabled",
                  type: "expect",
                  expression: "fencing_configured == true",
                  failure_message: "Fencing is not configured for all nodes."
                }
              ],
              when: "node_count > 0",
              premium: false
            }
          ]
        }
      },
      unprocessable_entity: UnprocessableEntity.response()
    ]

  def catalog(conn, params) do
    catalog = Catalog.get_catalog(params)
    render(conn, catalog: catalog)
  end

  operation :selectable_checks,
    summary: "List selectable checks for a given execution group and environment",
    tags: ["Wanda checks"],
    parameters: [
      group_id: [
        in: :path,
        description: "Identifier of the group for which selectable checks should be listed",
        type: %Schema{
          type: :string,
          format: :uuid
        },
        example: "00000000-0000-0000-0000-000000000001"
      ],
      env: [
        in: :query,
        description: "env variables",
        explode: true,
        style: :form,
        schema: V2Env
      ]
    ],
    responses: [
      ok: {"Selectable checks response", "application/json", SelectableChecksResponse}
    ]

  def selectable_checks(conn, params) do
    {group_id, updated_params} = Map.pop(params, :group_id)

    render(conn, %{
      selectable_checks: Catalog.get_catalog_for_group(group_id, updated_params)
    })
  end
end

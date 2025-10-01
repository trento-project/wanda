defmodule WandaWeb.Schemas.V1.Catalog.CatalogResponse do
  @moduledoc """
  Checks catalog response API spec
  """

  alias OpenApiSpex.Schema
  alias WandaWeb.Schemas.V1.Catalog.Check

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "CatalogResponse",
      deprecated: true,
      description:
        "Represents the response for a catalog listing, including a list of catalog checks and their details.",
      type: :object,
      additionalProperties: false,
      properties: %{
        items: %Schema{
          type: :array,
          description:
            "A list of catalog checks included in the response, each with metadata and configuration options.",
          items: Check
        }
      },
      example: %{
        items: [
          %{
            id: "156F64",
            name: "Corosync `token` timeout",
            group: "Corosync",
            description: "Corosync `token` timeout is set to the correct value",
            remediation:
              "The value of the Corosync `token` timeout is not set as recommended. Adjust the corosync `token` timeout as recommended...",
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
    struct?: false
  )
end

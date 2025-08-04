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
      description: "Checks catalog listing response",
      type: :object,
      additionalProperties: false,
      properties: %{
        items: %Schema{type: :array, description: "List of catalog checks", items: Check}
      },
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
    struct?: false
  )
end

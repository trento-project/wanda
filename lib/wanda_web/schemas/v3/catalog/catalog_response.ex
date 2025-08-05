defmodule WandaWeb.Schemas.V3.Catalog.CatalogResponse do
  @moduledoc """
  Checks catalog response API spec
  """

  alias OpenApiSpex.Schema
  alias WandaWeb.Schemas.V3.Catalog.Check

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "CatalogResponse",
      description:
        "This object represents the response for a catalog listing, including all available checks.",
      type: :object,
      additionalProperties: false,
      properties: %{
        items: %Schema{
          type: :array,
          description: "An array containing all catalog checks included in the response.",
          items: Check
        }
      },
      example: %{
        items: [
          %{
            id: "SLES-HA-1",
            name: "Cluster node fencing configured",
            group: "SLES-HA",
            description:
              "This check verifies whether fencing is configured for all cluster nodes to ensure high availability.",
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
                ],
                customization_disabled: false
              }
            ],
            expectations: [
              %{
                name: "fencing_enabled",
                type: "expect_enum",
                expression: "fencing_configured == true",
                failure_message: "Fencing is not configured for all nodes.",
                warning_message: "Warning: fencing may not be fully configured."
              }
            ],
            when: "node_count > 0",
            premium: false,
            customization_disabled: true
          }
        ]
      }
    },
    struct?: false
  )
end

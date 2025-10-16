defmodule WandaWeb.Schemas.V3.Catalog.CatalogResponse do
  @moduledoc """
  Checks catalog response API spec
  """

  alias OpenApiSpex.Schema
  alias WandaWeb.Schemas.V3.Catalog.Check

  require OpenApiSpex

  @items_example [
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

  OpenApiSpex.schema(
    %{
      title: "CatalogResponseV3",
      description:
        "This object represents the response for a catalog listing, including all available checks.",
      type: :object,
      additionalProperties: false,
      properties: %{
        items: %Schema{
          type: :array,
          description: "An array containing all catalog checks included in the response.",
          items: Check,
          example: @items_example
        }
      },
      example: %{
        items: @items_example
      }
    },
    struct?: false
  )
end

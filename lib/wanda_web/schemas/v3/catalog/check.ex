defmodule WandaWeb.Schemas.V3.Catalog.Check do
  @moduledoc """
  Individual check of the catalog response API spec
  """

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "Check",
      description: "A single check from the catalog",
      type: :object,
      additionalProperties: false,
      properties: %{
        id: %Schema{type: :string, description: "Check ID"},
        name: %Schema{type: :string, description: "Check name"},
        group: %Schema{type: :string, description: "Check group"},
        description: %Schema{type: :string, description: "Check description"},
        remediation: %Schema{type: :string, description: "Check remediation"},
        metadata: %Schema{
          type: :object,
          description: "Check metadata",
          nullable: true
        },
        severity: %Schema{
          type: :string,
          description: "Check severity: critical|warning",
          enum: [:critical, :warning]
        },
        facts: %Schema{
          type: :array,
          items: %Schema{
            type: :object,
            additionalProperties: false,
            properties: %{
              name: %Schema{type: :string, description: "Fact name"},
              gatherer: %Schema{type: :string, description: "Used gatherer"},
              argument: %Schema{type: :string, description: "Argument for the gatherer"}
            },
            required: [:name, :gatherer, :argument]
          }
        },
        values: %Schema{
          type: :array,
          items: %Schema{
            type: :object,
            additionalProperties: false,
            properties: %{
              name: %Schema{type: :string, description: "Value name"},
              default: %Schema{
                oneOf: [%Schema{type: :string}, %Schema{type: :number}, %Schema{type: :boolean}],
                description: "Default value. Used if none of the conditions matches"
              },
              conditions: %Schema{
                type: :array,
                items: %Schema{
                  type: :object,
                  additionalProperties: false,
                  properties: %{
                    value: %Schema{
                      oneOf: [
                        %Schema{type: :string},
                        %Schema{type: :number},
                        %Schema{type: :boolean}
                      ],
                      description: "Value for this condition"
                    },
                    expression: %Schema{
                      type: :string,
                      description: "Expression to be evaluated to use the current value"
                    }
                  },
                  required: [:value, :expression]
                }
              },
              customization_disabled: %Schema{
                type: :boolean,
                description: "Whether the value is customizable or not"
              }
            },
            required: [:name, :default, :conditions, :customization_disabled]
          }
        },
        expectations: %Schema{
          type: :array,
          items: %Schema{
            type: :object,
            additionalProperties: false,
            properties: %{
              name: %Schema{type: :string, description: "Expectation name"},
              type: %Schema{
                type: :string,
                description: "Expectation type",
                enum: [:unknown, :expect, :expect_same, :expect_enum]
              },
              expression: %Schema{
                type: :string,
                description: "Expression to be evaluated to get the expectation result"
              },
              failure_message: %Schema{
                type: :string,
                nullable: true,
                description: "Message returned when the check fails"
              },
              warning_message: %Schema{
                type: :string,
                nullable: true,
                description:
                  "Message returned when the check return value is warning. Only available for `expect_enum` expectations"
              }
            },
            required: [:name, :type, :expression, :failure_message]
          }
        },
        when: %Schema{
          type: :string,
          description: "Expression to determine whether a check should run",
          nullable: true
        },
        premium: %Schema{
          type: :boolean,
          description: "Check is Premium or not",
          deprecated: true
        },
        customization_disabled: %Schema{
          type: :boolean,
          description: "Whether the check is customizable or not"
        }
      },
      required: [
        :id,
        :name,
        :group,
        :description,
        :remediation,
        :metadata,
        :severity,
        :facts,
        :values,
        :expectations,
        :when,
        :premium,
        :customization_disabled
      ],
      example: %{
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
        customization_disabled: false
      }
    },
    struct?: false
  )
end

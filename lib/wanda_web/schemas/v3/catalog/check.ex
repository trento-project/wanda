defmodule WandaWeb.Schemas.V3.Catalog.Check do
  @moduledoc """
  Individual check of the catalog response API spec
  """

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "CheckV3",
      description:
        "This object represents a single check from the catalog, including its configuration, metadata, and validation logic.",
      type: :object,
      additionalProperties: false,
      properties: %{
        id: %Schema{
          type: :string,
          description: "A unique identifier for the check in the catalog."
        },
        name: %Schema{
          type: :string,
          description: "The name assigned to the check for identification and reporting purposes."
        },
        group: %Schema{
          type: :string,
          description:
            "The logical group to which the check belongs, used for organization and filtering."
        },
        description: %Schema{
          type: :string,
          description:
            "A detailed explanation of the check, outlining its purpose and expected behavior."
        },
        remediation: %Schema{
          type: :string,
          description:
            "Guidance or steps to resolve issues detected by the check, helping users remediate problems."
        },
        metadata: %Schema{
          type: :object,
          description:
            "Additional metadata associated with the check, providing context and categorization.",
          nullable: true
        },
        severity: %Schema{
          type: :string,
          description:
            "Indicates the severity level of the check, such as critical or warning, to help prioritize remediation.",
          enum: [:critical, :warning]
        },
        facts: %Schema{
          type: :array,
          items: %Schema{
            type: :object,
            additionalProperties: false,
            properties: %{
              name: %Schema{
                type: :string,
                description: "The label for the fact gathered for the check."
              },
              gatherer: %Schema{
                type: :string,
                description: "The gatherer used to collect the fact for the check."
              },
              argument: %Schema{
                type: :string,
                description: "The argument provided to the gatherer for fact collection."
              }
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
              name: %Schema{
                type: :string,
                description: "The label for the value used in the check."
              },
              default: %Schema{
                oneOf: [%Schema{type: :string}, %Schema{type: :number}, %Schema{type: :boolean}],
                description:
                  "The default value used if none of the conditions matches for the check."
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
                      description: "The value to be used for this condition in the check."
                    },
                    expression: %Schema{
                      type: :string,
                      description:
                        "The expression to be evaluated to use the current value for the check."
                    }
                  },
                  required: [:value, :expression]
                }
              },
              customization_disabled: %Schema{
                type: :boolean,
                description: "Indicates whether the value is customizable or not for this check."
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
              name: %Schema{
                type: :string,
                description: "A label that identifies the expectation for the check."
              },
              type: %Schema{
                type: :string,
                description:
                  "Specifies the type of expectation for the check, such as expect or expect_same.",
                enum: [:unknown, :expect, :expect_same, :expect_enum]
              },
              expression: %Schema{
                type: :string,
                description:
                  "The expression to be evaluated to get the expectation result for the check."
              },
              failure_message: %Schema{
                type: :string,
                nullable: true,
                description:
                  "A message returned when the check fails, providing context for troubleshooting."
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
        customization_disabled: false
      }
    },
    struct?: false
  )
end

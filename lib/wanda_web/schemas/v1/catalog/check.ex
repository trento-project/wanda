defmodule WandaWeb.Schemas.V1.Catalog.Check do
  @moduledoc """
  Individual check of the catalog response API spec
  """

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "Check",
      deprecated: true,
      description:
        "Represents a single check from the catalog, including its metadata, configuration, and validation logic.",
      type: :object,
      additionalProperties: false,
      properties: %{
        id: %Schema{
          type: :string,
          description: "The unique identifier of the check in the catalog."
        },
        name: %Schema{
          type: :string,
          description:
            "The name of the check in the catalog, used for identification and reporting."
        },
        group: %Schema{
          type: :string,
          description: "The group to which the check belongs, providing logical organization."
        },
        description: %Schema{
          type: :string,
          description: "A description of the check, outlining its purpose and expected behavior."
        },
        remediation: %Schema{
          type: :string,
          description:
            "A remediation message for the check, providing guidance on resolving issues detected."
        },
        metadata: %Schema{
          type: :object,
          description:
            "Metadata associated with the check, providing additional context and categorization.",
          nullable: true
        },
        severity: %Schema{
          type: :string,
          description:
            "The severity of the check, such as critical or warning, indicating its impact.",
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
                description: "The name of the fact gathered for the check."
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
                description: "The name of the value used in the check."
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
              }
            },
            required: [:name, :default, :conditions]
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
                description: "The name of the expectation for the check."
              },
              type: %Schema{
                type: :string,
                description:
                  "The type of expectation for the check, such as expect or expect_same.",
                enum: [:unknown, :expect, :expect_same]
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
              }
            },
            required: [:name, :type, :expression, :failure_message]
          }
        },
        when: %Schema{
          type: :string,
          description:
            "An expression to determine whether a check should run, allowing for conditional execution.",
          nullable: true
        },
        premium: %Schema{
          type: :boolean,
          description: "Check is Premium or not",
          deprecated: true
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
        :premium
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
    },
    struct?: false
  )
end

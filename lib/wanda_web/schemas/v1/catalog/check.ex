defmodule WandaWeb.Schemas.V1.Catalog.Check do
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
                        %Schema{type: :boolean},
                        %Schema{type: :array},
                        %Schema{type: :object}
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
              name: %Schema{type: :string, description: "Expectation name"},
              type: %Schema{
                type: :string,
                description: "Expectation type",
                enum: [:unknown, :expect, :expect_same]
              },
              expression: %Schema{
                type: :string,
                description: "Expression to be evaluated to get the expectation result"
              },
              failure_message: %Schema{
                type: :string,
                nullable: true,
                description: "Message returned when the check fails"
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
      ]
    },
    struct?: false
  )
end

defmodule WandaWeb.Schemas.V3.Catalog.Check do
  @moduledoc """
  Individual check of the catalog response API spec
  """

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(%{
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
        nullable: true,
        description: "Optional metadata for the check"
      },
      when: %Schema{
        type: :string,
        description: "Expression to determine whether a check should run",
        nullable: true
      },
      severity: %Schema{
        type: :string,
        description: "Check severity: critical|warning",
        enum: [:critical, :warning]
      },
      premium: %Schema{
        type: :boolean,
        description: "Check is Premium or not"
      },
      facts: %Schema{
        type: :array,
        items: %Schema{
          type: :object,
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
            }
          },
          required: [:name, :default, :conditions]
        }
      },
      expectations: %Schema{
        type: :array,
        items: %Schema{
          type: :object,
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
          required: [:name, :type, :expression]
        }
      }
    },
    required: [:id, :name, :severity, :facts, :values, :expectations]
  })
end

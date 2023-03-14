defmodule WandaWeb.Schemas.CatalogResponse.Check do
  @moduledoc """
  Individual check of the catalog response API spec
  """

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "Check",
    description: "A single check from the catalog",
    type: :object,
    properties: %{
      id: %Schema{type: :string, description: "Check ID"},
      name: %Schema{type: :string, description: "Check name"},
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
            name: %Schema{type: :string, description: "Expecation name"},
            type: %Schema{
              type: :string,
              description: "Expectation type",
              enum: [:expect, :expect_same]
            },
            expression: %Schema{
              type: :string,
              description: "Expression to be evaluated to get the expectation result"
            },
            failure_message: %Schema{
              type: :string,
              nullable: true,
              description: "Expression to be evaluated in case of failure"
            }
          },
          required: [:name, :type, :expression]
        }
      }
    },
    required: [:id, :name, :severity, :facts, :values, :expectations]
  })
end

defmodule WandaWeb.Schemas.V1.ChecksSelection.SelectableChecksResponse do
  @moduledoc """
  Response representing the list of selectable checks for a given execution group and environment.
  """

  alias WandaWeb.Schemas.V1.ChecksSelection.{CustomizedCheckValue, NotCustomizedCheckValue}

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "SelectableChecksResponse",
      description: "List of selectable checks for a given execution group and environment",
      type: :object,
      additionalProperties: false,
      properties: %{
        items: %Schema{
          type: :array,
          description: "List of Selectable Checks",
          example: [
            %{
              id: "check_1",
              name: "Check 1",
              group: "group_a",
              description: "Sample check",
              values: [],
              customizable: true,
              customized: false
            }
          ],
          items: %Schema{
            description: "A check that can be selected and customized for execution.",
            type: :object,
            additionalProperties: false,
            properties: %{
              id: %Schema{type: :string, description: "Check ID"},
              name: %Schema{type: :string, description: "Check name"},
              group: %Schema{type: :string, description: "Check group"},
              description: %Schema{type: :string, description: "Check description"},
              values: %Schema{
                type: :array,
                example: [
                  %{
                    name: "threshold",
                    default_value: 10,
                    custom_value: 15,
                    customizable: true
                  },
                  %{
                    name: "enabled",
                    default_value: true,
                    customizable: false
                  }
                ],
                items: %Schema{
                  oneOf: [
                    CustomizedCheckValue,
                    NotCustomizedCheckValue
                  ]
                }
              },
              customizable: %Schema{
                type: :boolean,
                description: "Whether the check is customizable or not"
              },
              customized: %Schema{
                type: :boolean,
                description: "Whether the check has been customized or not"
              }
            },
            required: [:id, :name, :group, :description, :values, :customizable, :customized]
          }
        }
      }
    },
    struct?: false
  )
end

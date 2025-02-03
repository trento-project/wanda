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
          items: %Schema{
            title: "SelectableCheck",
            type: :object,
            additionalProperties: false,
            properties: %{
              id: %Schema{type: :string, description: "Check ID"},
              name: %Schema{type: :string, description: "Check name"},
              group: %Schema{type: :string, description: "Check group"},
              description: %Schema{type: :string, description: "Check description"},
              values: %Schema{
                type: :array,
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
              }
            },
            required: [:id, :name, :group, :description, :values, :customizable]
          }
        }
      }
    },
    struct?: false
  )
end

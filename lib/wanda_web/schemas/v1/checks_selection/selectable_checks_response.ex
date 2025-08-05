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
      description:
        "Represents the list of selectable checks for a given execution group and environment, including details for customization and selection.",
      type: :object,
      additionalProperties: false,
      properties: %{
        items: %Schema{
          type: :array,
          description:
            "A list of selectable checks available for execution, each with customization options and metadata.",
          items: %Schema{
            description:
              "A check that can be selected and customized for execution, providing flexibility in validation and reporting.",
            type: :object,
            additionalProperties: false,
            properties: %{
              id: %Schema{
                type: :string,
                description: "The unique identifier of the check available for selection."
              },
              name: %Schema{
                type: :string,
                description: "The name of the check available for selection and customization."
              },
              group: %Schema{
                type: :string,
                description: "The group to which the selectable check belongs."
              },
              description: %Schema{
                type: :string,
                description:
                  "A description of the selectable check, outlining its purpose and expected behavior."
              },
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
                description:
                  "Indicates whether the check can be customized for execution, allowing for tailored validation."
              },
              customized: %Schema{
                type: :boolean,
                description:
                  "Indicates whether the check has already been customized for execution, reflecting user modifications."
              }
            },
            required: [:id, :name, :group, :description, :values, :customizable, :customized]
          }
        }
      },
      example: %{
        items: [
          %{
            id: "check_1",
            name: "Check 1",
            group: "group_a",
            description:
              "A sample selectable check for demonstration purposes, showing customization and selection options.",
            values: [
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
            customizable: true,
            customized: false
          }
        ]
      }
    },
    struct?: false
  )
end

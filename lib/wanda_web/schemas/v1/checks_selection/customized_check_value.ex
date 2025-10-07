defmodule WandaWeb.Schemas.V1.ChecksSelection.CustomizedCheckValue do
  @moduledoc """
  A Customized Check Value
  """

  alias OpenApiSpex.Schema

  require OpenApiSpex

  @value_types [
    %Schema{type: :string},
    %Schema{anyOf: [%Schema{type: :integer}, %Schema{type: :number}]},
    %Schema{type: :boolean}
  ]

  OpenApiSpex.schema(
    %{
      title: "CustomizedCheckValueV1",
      description:
        "Represents a single customized check value, including its name, custom value, default value, and customization status.",
      type: :object,
      additionalProperties: false,
      example: %{
        name: "threshold",
        custom_value: 15,
        default_value: 10,
        customizable: true
      },
      properties: %{
        name: %Schema{type: :string, description: "The name of the customized check value."},
        custom_value: %Schema{
          oneOf: @value_types,
          description:
            "The custom value that overrides the default value for this check, allowing for tailored validation."
        },
        default_value: %Schema{
          oneOf: @value_types,
          description:
            "The original value as defined by specification, resolved based on the environment."
        },
        customizable: %Schema{
          type: :boolean,
          description:
            "Indicates whether the check value can be customized for execution, allowing for tailored validation."
        }
      },
      required: [:name, :custom_value, :default_value, :customizable]
    },
    struct?: false
  )
end

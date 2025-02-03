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
      title: "CustomizedCheckValue",
      description: "A single customized check value",
      type: :object,
      additionalProperties: false,
      properties: %{
        name: %Schema{type: :string, description: "Value name"},
        customization: %Schema{
          oneOf: @value_types,
          description: "Represents the custom value that overrides the current one."
        },
        current_value: %Schema{
          oneOf: @value_types,
          description:
            "Value that is currently being used for the check based on the environment."
        },
        customizable: %Schema{
          type: :boolean,
          description: "Whether the check is customizable or not"
        }
      },
      required: [:name, :customization, :current_value, :customizable]
    },
    struct?: false
  )
end

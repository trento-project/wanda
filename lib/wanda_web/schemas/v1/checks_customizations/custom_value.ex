defmodule WandaWeb.Schemas.V1.ChecksCustomizations.CustomValue do
  @moduledoc """
  Custom value to be applied or already applied to a check
  """

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "CustomValueV1",
      description:
        "Represents a single custom value to be applied or already applied to a check, including its name and overriding value.",
      type: :object,
      additionalProperties: false,
      example: %{
        name: "threshold",
        value: 15
      },
      properties: %{
        name: %Schema{
          type: :string,
          description: "The name of the specific value to be customized for the check."
        },
        value: %Schema{
          description:
            "The overriding value to be applied to the check, replacing the default or previous value for customization purposes.",
          oneOf: [
            %Schema{type: :string},
            %Schema{type: :integer},
            %Schema{type: :boolean}
          ]
        }
      },
      required: [:name, :value]
    },
    struct?: false
  )
end

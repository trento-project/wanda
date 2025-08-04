defmodule WandaWeb.Schemas.V1.ChecksCustomizations.CustomValue do
  @moduledoc """
  Custom value to be applied or already applied to a check
  """

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "CustomValue",
      description: "A single custom value to be applied or already applied to a check",
      type: :object,
      additionalProperties: false,
      example: %{
        name: "threshold",
        value: 15
      },
      properties: %{
        name: %Schema{type: :string, description: "Name of the specific value to be customized"},
        value: %Schema{
          description: "Overriding value",
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

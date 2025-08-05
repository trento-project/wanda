defmodule WandaWeb.Schemas.V1.ChecksCustomizations.CustomizationRequest do
  @moduledoc """
  Request to customize a check
  """

  alias OpenApiSpex.Schema
  alias WandaWeb.Schemas.V1.ChecksCustomizations.CustomValue

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "CustomizationRequest",
      description:
        "Represents a request to customize a check, including the list of values to be customized for tailored validation.",
      type: :object,
      additionalProperties: false,
      minProperties: 1,
      example: %{
        values: [
          %{
            name: "threshold",
            value: 15
          },
          %{
            name: "enabled",
            value: true
          }
        ]
      },
      properties: %{
        values: %Schema{
          type: :array,
          description:
            "A list of values to be customized for the check, allowing for flexible and targeted configuration.",
          items: CustomValue,
          minItems: 1
        }
      },
      required: [:values]
    },
    struct?: false
  )
end

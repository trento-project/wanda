defmodule WandaWeb.Schemas.V1.ChecksCustomizations.CustomizationResponse do
  @moduledoc """
  Response for a customization operation
  """
  alias WandaWeb.Schemas.V1.ChecksCustomizations.CustomValue

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "CustomizationResponse",
      description:
        "Represents the response for a customization operation, including the list of custom values applied to a check.",
      type: :object,
      additionalProperties: false,
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
            "A list of custom values that have been applied to the check, reflecting the customization performed.",
          items: CustomValue
        }
      }
    },
    struct?: false
  )
end

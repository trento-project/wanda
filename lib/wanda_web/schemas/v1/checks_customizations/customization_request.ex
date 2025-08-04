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
      description: "Request to customize a check",
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
          description: "List of values to customize",
          items: CustomValue,
          minItems: 1
        }
      },
      required: [:values]
    },
    struct?: false
  )
end

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
      description: "Response for a customization",
      type: :object,
      additionalProperties: false,
      properties: %{
        values: %Schema{
          type: :array,
          description: "List of the custom values applied",
          items: CustomValue
        }
      }
    },
    struct?: false
  )
end

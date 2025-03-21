defmodule WandaWeb.Schemas.Forbidden do
  @moduledoc """
  403 - Forbidden
  """

  alias OpenApiSpex.Operation
  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "Forbidden",
      type: :object,
      additionalProperties: false,
      properties: %{
        errors: %Schema{
          type: :array,
          items: %Schema{
            type: :object,
            properties: %{
              detail: %Schema{
                type: :string,
                example: "The requested operation could not be performed."
              },
              title: %Schema{type: :string, example: "Forbidden"}
            }
          }
        }
      }
    },
    struct?: false
  )

  def response do
    Operation.response(
      "Forbidden",
      "application/json",
      __MODULE__
    )
  end
end

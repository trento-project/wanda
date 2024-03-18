defmodule WandaWeb.Schemas.BadRequest do
  @moduledoc """
  Bad Request
  """
  alias OpenApiSpex.Operation
  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "BadRequest",
    type: :object,
    additionalProperties: false,
    properties: %{
      errors: %Schema{
        type: :array,
        items: %Schema{
          type: :object,
          additionalProperties: false,
          properties: %{
            detail: %Schema{
              type: :string,
              example: "Invalid request payload."
            },
            title: %Schema{type: :string, example: "Bad Request"}
          }
        }
      }
    }
  })

  def response do
    Operation.response(
      "Bad Request",
      "application/json",
      __MODULE__
    )
  end
end

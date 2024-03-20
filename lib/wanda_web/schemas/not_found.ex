defmodule WandaWeb.Schemas.NotFound do
  @moduledoc """
  404 - Not Found
  """
  alias OpenApiSpex.Operation
  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "NotFound",
    type: :object,
    additionalProperties: false,
    properties: %{
      errors: %Schema{
        type: :array,
        items: %Schema{
          type: :object,
          additionalProperties: false,
          properties: %{
            detail: %Schema{type: :string, example: "The requested resource cannot be found."},
            title: %Schema{type: :string, example: "Not Found"}
          }
        }
      }
    }
  })

  def response do
    Operation.response(
      "Not Found",
      "application/json",
      __MODULE__
    )
  end
end

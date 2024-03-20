defmodule WandaWeb.Schemas.Ready do
  @moduledoc """
  Ready
  """
  alias OpenApiSpex.Operation
  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(%Schema{
    title: "Ready",
    type: :object,
    additionalProperties: false,
    example: %{
      ready: true
    },
    properties: %{
      ready: %Schema{
        description: "Wanda platform ready",
        type: :boolean
      }
    }
  })

  def response do
    Operation.response(
      "Ready",
      "application/json",
      __MODULE__
    )
  end
end

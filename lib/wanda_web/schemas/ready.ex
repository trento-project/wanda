defmodule WandaWeb.Schemas.Ready do
  @moduledoc """
  Ready.
  """
  alias OpenApiSpex.Operation
  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %Schema{
      title: "Ready",
      description:
        "This response provides the readiness status of the Wanda platform, indicating whether it is ready to accept requests.",
      type: :object,
      example: %{
        ready: true
      },
      additionalProperties: false,
      properties: %{
        ready: %Schema{
          description:
            "Indicates whether the Trento Web platform is ready to accept requests and operate normally.",
          type: :boolean
        }
      }
    },
    struct?: false
  )

  def response do
    Operation.response(
      "This response provides the readiness status of the Wanda platform, indicating whether it is ready to accept requests.",
      "application/json",
      __MODULE__
    )
  end
end

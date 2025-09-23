defmodule WandaWeb.Schemas.Health do
  @moduledoc """
  Healthcheck
  """

  alias OpenApiSpex.Operation
  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %Schema{
      title: "Health",
      description:
        "This response provides the health status of the checks/operations platform platform, including the status of its database connection.",
      type: :object,
      example: %{
        database: "pass"
      },
      additionalProperties: false,
      properties: %{
        database: %Schema{
          description:
            "This field shows the current status of the database connection for the checks/operations platform platform.",
          type: :string,
          enum: ["pass", "fail"],
          example: "pass"
        }
      }
    },
    struct?: false
  )

  def response do
    Operation.response(
      "This response provides the health status of the checks/operations platform, including the status of its database connection.",
      "application/json",
      __MODULE__
    )
  end
end

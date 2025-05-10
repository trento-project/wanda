defmodule WandaWeb.Schemas.Health do
  @moduledoc """
  Healthcheck
  """
  alias OpenApiSpex.Operation
  alias OpenApiSpex.Schema

  require OpenApiSpex

  @status_enum ["pass", "fail"]

  OpenApiSpex.schema(
    %Schema{
      title: "Health",
      type: :object,
      additionalProperties: false,
      example: %{
        database: "pass",
        catalog: "pass"
      },
      properties: %{
        database: %Schema{
          description: "The status of the database connection",
          type: :string,
          enum: @status_enum
        },
        catalog: %Schema{
          description: "The status of the checks catalog",
          type: :string,
          enum: @status_enum
        }
      }
    },
    struct?: false
  )

  def response do
    Operation.response(
      "Health",
      "application/json",
      __MODULE__
    )
  end
end

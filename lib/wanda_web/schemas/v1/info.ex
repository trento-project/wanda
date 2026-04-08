defmodule WandaWeb.Schemas.V1.Info do
  @moduledoc """
  Info response schema.
  """

  alias OpenApiSpex.Operation
  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %Schema{
      title: "InfoV1",
      description:
        "This response provides service discovery information about the current Wanda instance.",
      type: :object,
      example: %{
        name: "wanda",
        version: "2.0.0",
        checks_version: "1.0.0"
      },
      additionalProperties: false,
      properties: %{
        name: %Schema{
          description: "The service name.",
          type: :string,
          example: "wanda"
        },
        version: %Schema{
          description: "The version of the running Wanda application.",
          type: :string,
          example: "2.0.0"
        },
        checks_version: %Schema{
          description: "The version of the mounted checks catalog.",
          type: :string,
          example: "1.0.0",
          nullable: true
        }
      },
      required: [:name, :version, :checks_version]
    },
    struct?: false
  )

  def response do
    Operation.response(
      "This response provides service discovery information about the current Wanda instance.",
      "application/json",
      __MODULE__
    )
  end
end

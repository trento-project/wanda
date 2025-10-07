defmodule WandaWeb.Schemas.V1.BadRequest do
  @moduledoc """
  Bad Request.
  """

  alias OpenApiSpex.Operation
  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "BadRequestV1",
      description:
        "This response indicates that the request was malformed or contained invalid parameters, and could not be processed.",
      type: :object,
      additionalProperties: false,
      example: %{
        errors: [
          %{
            detail: "Invalid request payload.",
            title: "Bad Request"
          }
        ]
      },
      properties: %{
        errors: %Schema{
          type: :array,
          example: [
            %{
              detail: "Invalid request payload.",
              title: "Bad Request"
            }
          ],
          items: %Schema{
            type: :object,
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
    },
    struct?: false
  )

  def response do
    Operation.response(
      "This response indicates that the request was malformed or contained invalid parameters, and could not be processed.",
      "application/json",
      __MODULE__
    )
  end
end

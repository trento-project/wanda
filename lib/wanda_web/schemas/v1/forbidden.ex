defmodule WandaWeb.Schemas.V1.Forbidden do
  @moduledoc """
  403 - Forbidden.
  """

  alias OpenApiSpex.Operation
  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "Forbidden",
      description:
        "This response indicates that access to the requested resource or operation is forbidden due to insufficient permissions.",
      type: :object,
      additionalProperties: false,
      example: %{
        errors: [
          %{
            detail: "The requested operation could not be performed.",
            title: "Forbidden"
          }
        ]
      },
      properties: %{
        errors: %Schema{
          type: :array,
          example: [
            %{
              detail: "The requested operation could not be performed.",
              title: "Forbidden"
            }
          ],
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
      "This response indicates that access to the requested resource or operation is forbidden due to insufficient permissions.",
      "application/json",
      __MODULE__
    )
  end
end

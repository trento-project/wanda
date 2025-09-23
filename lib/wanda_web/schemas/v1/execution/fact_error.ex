defmodule WandaWeb.Schemas.V1.Execution.FactError do
  @moduledoc false

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "FactError",
      description:
        "Indicates that a fact could not be gathered during execution, providing details for troubleshooting data collection issues.",
      type: :object,
      additionalProperties: false,
      properties: %{
        check_id: %Schema{
          type: :string,
          description:
            "The unique identifier of the check for which the fact could not be gathered."
        },
        name: %Schema{
          type: :string,
          description: "The name of the fact that could not be gathered during execution."
        },
        type: %Schema{
          type: :string,
          description: "The type of error encountered during fact gathering."
        },
        message: %Schema{
          type: :string,
          description:
            "A detailed message describing the error encountered during fact gathering."
        }
      },
      required: [:check_id, :name, :type, :message],
      example: %{
        check_id: "156F64",
        name: "node_count",
        type: "gathering_error",
        message: "Timeout while gathering fact"
      }
    },
    struct?: false
  )
end

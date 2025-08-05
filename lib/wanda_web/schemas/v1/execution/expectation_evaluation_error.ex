defmodule WandaWeb.Schemas.V1.Execution.ExpectationEvaluationError do
  @moduledoc false

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "ExpectationEvaluationError",
      description:
        "Indicates that an error occurred during the evaluation of an expectation, providing details for troubleshooting.",
      type: :object,
      additionalProperties: false,
      properties: %{
        name: %Schema{
          type: :string,
          description: "The name of the expectation for which the error occurred."
        },
        message: %Schema{
          type: :string,
          description:
            "A detailed message describing the error encountered during expectation evaluation."
        },
        type: %Schema{
          type: :string,
          description:
            "The type of error encountered during expectation evaluation, such as validation or runtime error."
        }
      },
      required: [:name, :message, :type],
      example: %{
        name: "fencing_enabled",
        message: "Expression evaluation failed.",
        type: "evaluation_error"
      }
    },
    struct?: false
  )
end

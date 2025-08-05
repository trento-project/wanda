defmodule WandaWeb.Schemas.V1.Execution.ExpectationResult do
  @moduledoc false

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "ExpectationResult",
      description:
        "Represents the result of an expectation evaluation, including its name, result, type, and any failure message.",
      type: :object,
      additionalProperties: false,
      properties: %{
        name: %Schema{type: :string, description: "The name of the expectation being evaluated."},
        result: %Schema{
          type: :boolean,
          description: "Indicates whether the expectation condition was met during evaluation."
        },
        type: %Schema{
          type: :string,
          enum: [:unknown, :expect, :expect_same],
          description:
            "The type of evaluation performed for the expectation, such as expect or expect_same."
        },
        failure_message: %Schema{
          type: :string,
          nullable: true,
          description:
            "A message describing the failure, only available for scenarios where the expectation was not met."
        }
      },
      required: [:name, :result, :type],
      example: %{
        name: "fencing_enabled",
        result: true,
        type: "expect",
        failure_message: "Fencing is not configured for all nodes."
      }
    },
    struct?: false
  )
end

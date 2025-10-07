defmodule WandaWeb.Schemas.V1.Execution.ExpectationEvaluation do
  @moduledoc false

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "ExpectationEvaluationV1",
      deprecated: true,
      description:
        "Represents the result of evaluating an expectation, including its name, value, type, and any failure message.",
      type: :object,
      additionalProperties: false,
      properties: %{
        name: %Schema{type: :string, description: "The name of the expectation being evaluated."},
        return_value: %Schema{
          oneOf: [%Schema{type: :string}, %Schema{type: :number}, %Schema{type: :boolean}],
          description:
            "The value returned from the expectation evaluation, indicating the outcome of the check."
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
      required: [:name, :return_value, :type],
      example: %{
        name: "fencing_enabled",
        return_value: true,
        type: "expect",
        failure_message: "Fencing is not configured for all nodes."
      }
    },
    struct?: false
  )
end

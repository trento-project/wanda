defmodule WandaWeb.Schemas.V2.Execution.ExpectationEvaluation do
  @moduledoc false

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "ExpectationEvaluationV2",
      description:
        "This object describes the evaluation process and outcome for a specific expectation during a check execution.",
      type: :object,
      additionalProperties: false,
      properties: %{
        name: %Schema{
          type: :string,
          description: "A label that identifies the expectation being evaluated in the check."
        },
        return_value: %Schema{
          oneOf: [
            %Schema{type: :string},
            %Schema{type: :number},
            %Schema{type: :boolean},
            %Schema{type: :string, enum: [:passing, :warning, :critical]}
          ],
          description:
            "The value returned after evaluating the expectation for the check execution."
        },
        type: %Schema{
          type: :string,
          enum: [:unknown, :expect, :expect_same, :expect_enum],
          description:
            "Specifies the type of evaluation performed for the expectation in the check execution."
        },
        failure_message: %Schema{
          type: :string,
          nullable: true,
          description:
            "A message describing the reason for failure when the expectation is not met. Only available for certain scenarios."
        }
      },
      required: [:name, :return_value, :type],
      example: %{
        name: "fencing_enabled",
        return_value: "critical",
        type: "expect_enum",
        failure_message: "Fencing is not configured for all nodes."
      }
    },
    struct?: false
  )
end

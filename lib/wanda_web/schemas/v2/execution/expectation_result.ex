defmodule WandaWeb.Schemas.V2.Execution.ExpectationResult do
  @moduledoc false

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "ExpectationResultV2",
      description:
        "This object describes the outcome of an expectation evaluation during a check execution.",
      type: :object,
      additionalProperties: false,
      properties: %{
        name: %Schema{
          type: :string,
          description: "A label that identifies the expectation being evaluated in the check."
        },
        result: %Schema{
          oneOf: [
            %Schema{type: :string},
            %Schema{type: :number},
            %Schema{type: :boolean},
            %Schema{type: :string, enum: [:passing, :warning, :critical]}
          ],
          description:
            "The outcome value produced by evaluating the expectation condition during the check execution."
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

defmodule WandaWeb.Schemas.V2.Execution.ExpectationEvaluation do
  @moduledoc false

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "ExpectationEvaluation",
      description: "Evaluation of an expectation",
      type: :object,
      additionalProperties: false,
      properties: %{
        name: %Schema{type: :string, description: "Name"},
        return_value: %Schema{
          oneOf: [
            %Schema{type: :string},
            %Schema{type: :number},
            %Schema{type: :boolean},
            %Schema{type: :string, enum: [:passing, :warning, :critical]}
          ],
          description: "Return value"
        },
        type: %Schema{
          type: :string,
          enum: [:unknown, :expect, :expect_same, :expect_enum],
          description: "Evaluation type"
        },
        failure_message: %Schema{
          type: :string,
          nullable: true,
          description: "Failure message. Only available for `expect` scenarios"
        }
      },
      required: [:name, :return_value, :type]
    },
    struct?: false
  )
end

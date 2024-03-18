defmodule WandaWeb.Schemas.V2.Execution.ExpectationResult do
  @moduledoc false

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "ExpectationResult",
    description: "The result of an expectation",
    type: :object,
    additionalProperties: false,
    properties: %{
      name: %Schema{type: :string, description: "Expectation name"},
      result: %Schema{
        oneOf: [
          %Schema{type: :string},
          %Schema{type: :number},
          %Schema{type: :boolean},
          %Schema{type: :string, enum: [:passing, :warning, :critical]}
        ],
        description: "Result of the expectation condition"
      },
      type: %Schema{
        type: :string,
        enum: [:unknown, :expect, :expect_same, :expect_enum],
        description: "Evaluation type"
      },
      failure_message: %Schema{
        type: :string,
        nullable: true,
        description: "Failure message. Only available for `expect_same` scenarios"
      }
    },
    required: [:name, :result, :type]
  })
end

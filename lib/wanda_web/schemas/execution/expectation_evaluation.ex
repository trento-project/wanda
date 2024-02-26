defmodule WandaWeb.Schemas.ExecutionResponse.ExpectationEvaluation do
  @moduledoc false

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "ExpectationEvaluation",
    description: "Evaluation of an expectation",
    type: :object,
    properties: %{
      name: %Schema{type: :string, description: "Name"},
      return_value: %Schema{
        oneOf: [%Schema{type: :string}, %Schema{type: :number}, %Schema{type: :boolean}],
        description: "Return value"
      },
      type: %Schema{
        type: :string,
        enum: [:unknown, :expect, :expect_same],
        description: "Evaluation type"
      },
      failure_message: %Schema{
        type: :string,
        nullable: true,
        description: "Failure message. Only available for `expect` scenarios"
      }
    },
    required: [:name, :return_value, :type]
  })
end

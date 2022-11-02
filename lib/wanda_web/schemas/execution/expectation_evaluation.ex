defmodule WandaWeb.Schemas.ExecutionResponse.ExpectationEvaluation do
  @moduledoc false

  require OpenApiSpex

  alias OpenApiSpex.Schema

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
        enum: ["expect", "expect_same"],
        description: "Evaluation type"
      }
    },
    required: [:name, :return_value, :type]
  })
end

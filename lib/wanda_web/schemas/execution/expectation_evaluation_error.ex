defmodule WandaWeb.Schemas.ExecutionResponse.ExpectationEvaluationError do
  @moduledoc false

  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "ExpectationEvaluationError",
    description: "An error occurred during the evaluation of an expectation",
    type: :object,
    properties: %{
      name: %Schema{type: :string, description: "Expectation name"},
      message: %Schema{type: :string, description: "Error message"},
      type: %Schema{
        type: :string,
        enum: ["fact_missing_error", "illegal_expression_error"],
        description: "Error type"
      }
    },
    required: [:name, :message, :type]
  })
end

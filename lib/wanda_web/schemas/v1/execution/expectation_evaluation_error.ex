defmodule WandaWeb.Schemas.V1.Execution.ExpectationEvaluationError do
  @moduledoc false

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "ExpectationEvaluationError",
    description: "An error occurred during the evaluation of an expectation",
    type: :object,
    additionalProperties: false,
    properties: %{
      name: %Schema{type: :string, description: "Expectation name"},
      message: %Schema{type: :string, description: "Error message"},
      type: %Schema{
        type: :string,
        description: "Error type"
      }
    },
    required: [:name, :message, :type]
  })
end

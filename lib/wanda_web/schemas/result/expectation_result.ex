defmodule WandaWeb.Schemas.Result.ExpectationResult do
  @moduledoc false

  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "ExpectationResult",
    description: "The result of an expectation",
    type: :object,
    properties: %{
      name: %Schema{type: :string, description: "Expectation name"},
      result: %Schema{type: :boolean, description: "Result of the expectation condition"},
      type: %Schema{
        type: :string,
        enum: ["expect", "expect_same"],
        description: "Evaluation type"
      }
    },
    required: [:name, :result, :type]
  })
end

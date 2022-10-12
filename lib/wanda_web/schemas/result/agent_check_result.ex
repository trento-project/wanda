defmodule WandaWeb.Schemas.Result.AgentCheckResult do
  @moduledoc false

  require OpenApiSpex

  alias OpenApiSpex.Schema

  alias WandaWeb.Schemas.Result.{ExpectationEvaluation, ExpectationEvaluationError, Fact}

  OpenApiSpex.schema(%{
    title: "AgentCheckResult",
    description: "The result of check on a specific agent",
    type: :object,
    properties: %{
      agent_id: %Schema{type: :string, description: "Agent ID"},
      facts: %Schema{type: :array, items: Fact, description: "Facts gathered from the targets"},
      expectation_evaluations: %Schema{
        type: :array,
        items: %Schema{
          oneOf: [
            ExpectationEvaluation,
            ExpectationEvaluationError
          ]
        },
        description: "Result of the single expectation evaluation"
      }
    },
    required: [:agent_id, :facts, :expectation_evaluations]
  })
end
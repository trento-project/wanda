defmodule WandaWeb.Schemas.Result.AgentCheckError do
  @moduledoc false

  require OpenApiSpex

  alias OpenApiSpex.Schema

  alias WandaWeb.Schemas.Result.{ExpectationEvaluation, Fact}

  OpenApiSpex.schema(%{
    title: "AgentCheckError",
    description: "The result of check on a specific agent",
    type: :object,
    properties: %{
      agent_id: %Schema{type: :string, description: "Agent ID"},
      facts: %Schema{type: :array, items: Fact, description: "Facts gathered from the targets"},
      expectation_evaluations: %Schema{
        type: :array,
        items: ExpectationEvaluation,
        description: "Agent ID"
      }
    },
    required: [:agent_id, :facts, :expectation_evaluations]
  })
end

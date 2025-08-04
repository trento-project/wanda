defmodule WandaWeb.Schemas.V2.Execution.AgentCheckResult do
  @moduledoc false

  alias OpenApiSpex.Schema

  alias WandaWeb.Schemas.V1.Execution.{
    ExpectationEvaluationError,
    Fact
  }

  alias WandaWeb.Schemas.V2.Execution.ExpectationEvaluation

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "AgentCheckResult",
      description: "The result of check on a specific agent",
      type: :object,
      additionalProperties: false,
      properties: %{
        agent_id: %Schema{type: :string, format: :uuid, description: "Agent ID"},
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
      required: [:agent_id, :facts, :expectation_evaluations],
      example: %{
        agent_id: "a1b2c3d4-e5f6-7890-abcd-1234567890ab",
        facts: [%{check_id: "SLES-HA-1", name: "node_count", value: 3}],
        expectation_evaluations: [
          %{
            name: "fencing_enabled",
            type: "expect_enum",
            return_value: "critical"
          }
        ]
      }
    },
    struct?: false
  )
end

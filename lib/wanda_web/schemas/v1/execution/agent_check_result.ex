defmodule WandaWeb.Schemas.V1.Execution.AgentCheckResult do
  @moduledoc false

  alias OpenApiSpex.Schema

  alias WandaWeb.Schemas.V1.Execution.{
    ExpectationEvaluation,
    ExpectationEvaluationError,
    Fact,
    Value
  }

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "AgentCheckResult",
      description: "The result of check on a specific agent",
      type: :object,
      properties: %{
        agent_id: %Schema{type: :string, format: :uuid, description: "Agent ID"},
        facts: %Schema{type: :array, items: Fact, description: "Facts gathered from the targets"},
        values: %Schema{
          type: :array,
          items: Value,
          description: "Values resolved for the current execution"
        },
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
        values: [
          %{name: "fencing_configured", check_id: "SLES-HA-1", value: true, customized: false}
        ],
        expectation_evaluations: [
          %{
            name: "fencing_enabled",
            type: "expect",
            return_value: true
          }
        ]
      }
    },
    struct?: false
  )
end

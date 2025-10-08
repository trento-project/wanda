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
      title: "AgentCheckResultV1",
      deprecated: true,
      description:
        "Represents the result of a check performed on a specific agent, including gathered facts and expectation evaluations.",
      type: :object,
      additionalProperties: false,
      properties: %{
        agent_id: %Schema{
          type: :string,
          format: :uuid,
          description: "The unique identifier of the agent for which the check was performed."
        },
        facts: %Schema{
          type: :array,
          items: Fact,
          description: "Facts gathered from the target agent during the check execution."
        },
        values: %Schema{
          type: :array,
          items: Value,
          description:
            "Values resolved for the current execution, representing the computed results for the agent's check."
        },
        expectation_evaluations: %Schema{
          type: :array,
          items: %Schema{
            oneOf: [
              ExpectationEvaluation,
              ExpectationEvaluationError
            ]
          },
          description:
            "Result of the single expectation evaluation, indicating whether the expectation was met for the agent's check."
        }
      },
      required: [:agent_id, :facts, :expectation_evaluations],
      example: %{
        agent_id: "a1b2c3d4-e5f6-7890-abcd-1234567890ab",
        facts: [%{check_id: "156F64", name: "node_count", value: 3}],
        values: [
          %{name: "fencing_configured", check_id: "156F64", value: true, customized: false}
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

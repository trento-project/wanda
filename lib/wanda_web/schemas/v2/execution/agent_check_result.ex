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
      description:
        "This object represents the result of a check performed on a specific agent during the execution process.",
      type: :object,
      additionalProperties: false,
      properties: %{
        agent_id: %Schema{
          type: :string,
          format: :uuid,
          description:
            "A unique identifier for the agent that participated in the check execution."
        },
        facts: %Schema{
          type: :array,
          items: Fact,
          description:
            "An array of facts that were gathered from the agent during the execution process."
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
            "An array containing the results of each expectation evaluation performed for the agent during the check execution."
        }
      },
      required: [:agent_id, :facts, :expectation_evaluations],
      example: %{
        agent_id: "a1b2c3d4-e5f6-7890-abcd-1234567890ab",
        facts: [%{check_id: "156F64", name: "node_count", value: 3}],
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

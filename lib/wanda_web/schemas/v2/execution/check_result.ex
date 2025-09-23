defmodule WandaWeb.Schemas.V2.Execution.CheckResult do
  @moduledoc false

  alias OpenApiSpex.Schema

  alias WandaWeb.Schemas.V1.Execution.{AgentCheckError, AgentCheckResult, ExpectationResult}

  alias WandaWeb.Schemas.V2.Execution.ExpectationResult

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "CheckResult",
      description:
        "This object represents the result of a check execution, including expectation evaluations and agent-specific results.",
      type: :object,
      additionalProperties: false,
      properties: %{
        check_id: %Schema{
          type: :string,
          description: "A unique identifier for the check that was executed."
        },
        customized: %Schema{
          type: :boolean,
          description:
            "Specifies if the check was customized for this particular execution instance."
        },
        expectation_results: %Schema{
          type: :array,
          items: ExpectationResult,
          description:
            "An array containing the results of each expectation evaluated during the check execution."
        },
        agents_check_results: %Schema{
          type: :array,
          items: %Schema{
            oneOf: [
              AgentCheckResult,
              AgentCheckError
            ]
          },
          description:
            "An array containing the results of the check execution for each agent, including any errors encountered."
        },
        result: %Schema{
          type: :string,
          enum: ["passing", "warning", "critical"],
          description:
            "The overall result of the check execution, which may be passing, warning, or critical."
        }
      },
      required: [:check_id, :expectation_results, :agents_check_results, :result],
      example: %{
        check_id: "156F64",
        customized: false,
        expectation_results: [
          %{
            name: "fencing_enabled",
            result: true,
            type: "expect",
            failure_message: "Fencing is not configured for all nodes."
          }
        ],
        agents_check_results: [],
        result: "critical"
      }
    },
    struct?: false
  )
end

defmodule WandaWeb.Schemas.V1.Execution.CheckResult do
  @moduledoc false

  alias OpenApiSpex.Schema

  alias WandaWeb.Schemas.V1.Execution.{
    AgentCheckError,
    AgentCheckResult,
    ExpectationResult
  }

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "CheckResult",
      description: "The result of a check",
      type: :object,
      additionalProperties: false,
      properties: %{
        check_id: %Schema{type: :string, description: "Check ID"},
        customized: %Schema{type: :boolean, description: "Whether the check has been customized"},
        expectation_results: %Schema{type: :array, items: ExpectationResult},
        agents_check_results: %Schema{
          type: :array,
          items: %Schema{
            oneOf: [
              AgentCheckResult,
              AgentCheckError
            ]
          }
        },
        result: %Schema{
          type: :string,
          enum: ["passing", "warning", "critical"],
          description: "Result of the check"
        }
      },
      required: [:check_id, :expectation_results, :agents_check_results, :result],
      example: %{
        check_id: "SLES-HA-1",
        customized: false,
        expectation_results: [
          %{
            name: "fencing_enabled",
            result: false,
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

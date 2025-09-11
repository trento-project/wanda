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
      description:
        "Represents the result of a check execution, including expectation evaluations and customization status.",
      type: :object,
      additionalProperties: false,
      properties: %{
        check_id: %Schema{
          type: :string,
          description: "The unique identifier of the check for which the result is reported.",
          example: "SLES-HA-1"
        },
        customized: %Schema{
          type: :boolean,
          description:
            "Indicates whether the check has been customized for this execution, allowing for tailored validation.",
          example: false
        },
        expectation_results: %Schema{
          type: :array,
          items: ExpectationResult,
          description:
            "List of results for each expectation evaluated during the check, providing detailed outcome information.",
          example: [
            %{
              name: "fencing_enabled",
              result: true,
              type: "expect",
              failure_message: "Fencing is not configured for all nodes."
            }
          ]
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
            "The aggregated result of the check execution, summarizing the overall outcome for the check.",
          example: []
        },
        result: %Schema{
          type: :string,
          enum: ["passing", "warning", "critical"],
          description:
            "Aggregated result of the check execution. Possible values are: passing, warning, or critical.",
          example: "critical"
        }
      },
      required: [:check_id, :expectation_results, :agents_check_results, :result],
      example: %{
        check_id: "SLES-HA-1",
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

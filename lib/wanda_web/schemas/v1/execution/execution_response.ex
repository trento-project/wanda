defmodule WandaWeb.Schemas.V1.Execution.ExecutionResponse do
  @moduledoc """
  Execution item response API spec
  """

  alias OpenApiSpex.Schema

  alias WandaWeb.Schemas.V1.Execution.{
    CheckResult,
    Target
  }

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "ExecutionResponse",
      description:
        "Represents the details of an execution, including its status, timing, results, and associated targets. Can be running or completed.",
      type: :object,
      additionalProperties: false,
      properties: %{
        execution_id: %Schema{
          type: :string,
          format: :uuid,
          description: "The unique identifier of the execution."
        },
        group_id: %Schema{
          type: :string,
          format: :uuid,
          description: "The unique identifier of the group associated with the execution."
        },
        status: %Schema{
          type: :string,
          enum: ["running", "completed"],
          description:
            "The current status of the execution, indicating its progress or completion state."
        },
        started_at: %Schema{
          type: :string,
          format: :"date-time",
          description: "The timestamp indicating when the execution started."
        },
        completed_at: %Schema{
          type: :string,
          nullable: true,
          format: :"date-time",
          description: "The timestamp indicating when the execution was completed, if applicable."
        },
        result: %Schema{
          type: :string,
          nullable: true,
          enum: ["passing", "warning", "critical"],
          description:
            "The aggregated result of the execution, summarizing the overall outcome. Unknown for running executions."
        },
        targets: %Schema{
          type: :array,
          items: Target,
          description: "The list of targets involved in the execution."
        },
        critical_count: %Schema{
          type: :integer,
          nullable: true,
          description:
            "The number of checks that resulted in a critical outcome during the execution."
        },
        warning_count: %Schema{
          type: :integer,
          nullable: true,
          description:
            "The number of checks that resulted in a warning outcome during the execution."
        },
        passing_count: %Schema{
          type: :integer,
          nullable: true,
          description: "The number of checks that passed successfully during the execution."
        },
        timeout: %Schema{
          type: :array,
          nullable: true,
          items: %Schema{
            type: :string,
            format: :uuid,
            description: "The unique identifier of the agent that timed out during the execution."
          },
          description: "A list of agents that timed out during the execution process."
        },
        check_results: %Schema{
          type: :array,
          nullable: true,
          items: CheckResult,
          description:
            "The list of check results for this execution, providing detailed outcome information for each check."
        }
      },
      required: [
        :execution_id,
        :group_id,
        :status,
        :started_at,
        :completed_at,
        :result,
        :targets,
        :critical_count,
        :warning_count,
        :passing_count,
        :timeout,
        :check_results
      ],
      example: %{
        execution_id: "e1a2b3c4-d5f6-7890-abcd-1234567890ab",
        group_id: "353fd789-d8ae-4a1b-a9f9-3919bd773e79",
        status: "completed",
        started_at: "2025-08-04T10:00:00Z",
        completed_at: "2025-08-04T10:05:00Z",
        result: "critical",
        targets: [
          %{agent_id: "a1b2c3d4-e5f6-7890-abcd-1234567890ab", checks: ["156F64"]}
        ],
        critical_count: 1,
        warning_count: 0,
        passing_count: 0,
        timeout: [],
        check_results: [
          %{
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
        ]
      }
    },
    struct?: false
  )
end

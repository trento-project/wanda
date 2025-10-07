defmodule WandaWeb.Schemas.V2.Execution.ExecutionResponse do
  @moduledoc """
  Execution item response API spec
  """

  alias OpenApiSpex.Schema

  alias WandaWeb.Schemas.V1.Execution.Target

  alias WandaWeb.Schemas.V2.Execution.CheckResult

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "ExecutionResponseV2",
      description:
        "This object represents the details and status of an execution, which may be running or completed.",
      type: :object,
      additionalProperties: false,
      properties: %{
        execution_id: %Schema{
          type: :string,
          format: :uuid,
          description: "A unique identifier for the execution instance."
        },
        group_id: %Schema{
          type: :string,
          format: :uuid,
          description:
            "A unique identifier for the group associated with this execution instance."
        },
        status: %Schema{
          type: :string,
          enum: ["running", "completed"],
          description:
            "Indicates whether the execution is currently running or has been completed."
        },
        started_at: %Schema{
          type: :string,
          format: :"date-time",
          description: "The timestamp when the execution started."
        },
        completed_at: %Schema{
          type: :string,
          nullable: true,
          format: :"date-time",
          description: "The timestamp when the execution was completed, if available."
        },
        result: %Schema{
          type: :string,
          nullable: true,
          enum: ["passing", "warning", "critical"],
          description:
            "The overall result of the execution, which may be unknown if the execution is still running."
        },
        targets: %Schema{
          type: :array,
          items: Target,
          description: "An array of agents that participated in the execution process."
        },
        critical_count: %Schema{
          type: :integer,
          nullable: true,
          description:
            "The number of checks that resulted in a critical status during the execution."
        },
        warning_count: %Schema{
          type: :integer,
          nullable: true,
          description:
            "The number of checks that resulted in a warning status during the execution."
        },
        passing_count: %Schema{
          type: :integer,
          nullable: true,
          description:
            "The number of checks that resulted in a passing status during the execution."
        },
        timeout: %Schema{
          type: :array,
          nullable: true,
          items: %Schema{
            type: :string,
            format: :uuid,
            description: "A unique identifier for the agent that timed out during execution."
          },
          description:
            "An array of agents that did not complete the execution within the expected time frame."
        },
        check_results: %Schema{
          type: :array,
          nullable: true,
          items: CheckResult,
          description:
            "An array containing the results of each check performed during the execution."
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

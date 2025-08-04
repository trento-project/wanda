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
      description: "The representation of an execution, it may be a running or completed one",
      type: :object,
      additionalProperties: false,
      properties: %{
        execution_id: %Schema{type: :string, format: :uuid, description: "Execution ID"},
        group_id: %Schema{type: :string, format: :uuid, description: "Group ID"},
        status: %Schema{
          type: :string,
          enum: ["running", "completed"],
          description: "The status of the current execution"
        },
        started_at: %Schema{
          type: :string,
          format: :"date-time",
          description: "Execution start time"
        },
        completed_at: %Schema{
          type: :string,
          nullable: true,
          format: :"date-time",
          description: "Execution completion time"
        },
        result: %Schema{
          type: :string,
          nullable: true,
          enum: ["passing", "warning", "critical"],
          description: "Aggregated result of the execution, unknown for running ones"
        },
        targets: %Schema{type: :array, items: Target},
        critical_count: %Schema{
          type: :integer,
          nullable: true,
          description: "Number of checks with critical result"
        },
        warning_count: %Schema{
          type: :integer,
          nullable: true,
          description: "Number of checks with warning result"
        },
        passing_count: %Schema{
          type: :integer,
          nullable: true,
          description: "Number of checks with passing result"
        },
        timeout: %Schema{
          type: :array,
          nullable: true,
          items: %Schema{type: :string, format: :uuid, description: "Agent ID"},
          description: "Timed out agents"
        },
        check_results: %Schema{type: :array, nullable: true, items: CheckResult}
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
        group_id: "g1a2b3c4-d5f6-7890-abcd-1234567890ab",
        status: "completed",
        started_at: "2025-08-04T10:00:00Z",
        completed_at: "2025-08-04T10:05:00Z",
        result: "critical",
        targets: [
          %{agent_id: "a1b2c3d4-e5f6-7890-abcd-1234567890ab", checks: ["SLES-HA-1"]}
        ],
        critical_count: 1,
        warning_count: 0,
        passing_count: 0,
        timeout: [],
        check_results: [
          %{
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
        ]
      }
    },
    struct?: false
  )
end

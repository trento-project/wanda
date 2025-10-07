defmodule WandaWeb.Schemas.V2.Execution.ListExecutionsResponse do
  @moduledoc """
  Execution list response API spec
  """

  alias OpenApiSpex.Schema

  alias WandaWeb.Schemas.V2.Execution.ExecutionResponse

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "ListExecutionsResponseV2",
      description:
        "This schema represents a paginated response containing multiple execution records.",
      type: :object,
      additionalProperties: false,
      properties: %{
        items: %Schema{
          type: :array,
          items: ExecutionResponse,
          description: "An array containing the execution items included in this response page."
        },
        total_count: %Schema{
          type: :integer,
          description:
            "The total number of executions available in the system. This value is used for pagination purposes."
        }
      },
      example: %{
        items: [
          %{
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
        ],
        total_count: 1
      }
    },
    struct?: false
  )
end

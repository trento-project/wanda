defmodule WandaWeb.Schemas.V2.Execution.ListExecutionsResponse do
  @moduledoc """
  Execution list response API spec
  """

  alias OpenApiSpex.Schema

  alias WandaWeb.Schemas.V2.Execution.ExecutionResponse

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "ListExecutionsResponse",
      description: "The paginated list of executions",
      type: :object,
      additionalProperties: false,
      properties: %{
        items: %Schema{type: :array, items: ExecutionResponse},
        total_count: %Schema{type: :integer, description: "Total count of executions"}
      },
      example: %{
        items: [
          %{
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
        ],
        total_count: 1
      }
    },
    struct?: false
  )
end

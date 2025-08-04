defmodule WandaWeb.Schemas.V1.Operation.ListOperationsResponse do
  @moduledoc """
  Operation list response API spec
  """

  alias OpenApiSpex.Schema

  alias WandaWeb.Schemas.V1.Operation.OperationResponse

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "ListOperationsResponse",
      description: "The paginated list of operations",
      type: :object,
      additionalProperties: false,
      properties: %{
        items: %Schema{type: :array, items: OperationResponse},
        total_count: %Schema{type: :integer, description: "Total count of operations"}
      },
      example: %{
        items: [
          %{
            operation_id: "o1a2b3c4-d5f6-7890-abcd-1234567890ab",
            group_id: "g1a2b3c4-d5f6-7890-abcd-1234567890ab",
            status: "completed",
            result: "updated",
            name: "Install NGINX",
            description: "Installs the NGINX package on target agents.",
            operation: "install_package",
            targets: [
              %{
                agent_id: "a1b2c3d4-e5f6-7890-abcd-1234567890ab",
                arguments: %{"package" => "nginx", "version" => "1.18.0"}
              }
            ],
            agent_reports: [
              %{
                name: "install_package",
                operator: "equals",
                predicate: "package_installed == true",
                timeout: 60,
                agents: [
                  %{
                    agent_id: "a1b2c3d4-e5f6-7890-abcd-1234567890ab",
                    result: "updated",
                    diff: %{before: "absent", after: "present"},
                    error_message: ""
                  }
                ]
              }
            ],
            started_at: "2025-08-04T10:00:00Z",
            updated_at: "2025-08-04T10:01:00Z",
            completed_at: "2025-08-04T10:02:00Z"
          }
        ],
        total_count: 1
      }
    },
    struct?: false
  )
end

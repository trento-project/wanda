defmodule WandaWeb.Schemas.V1.Operation.OperationResponse do
  @moduledoc """
  Operation item response API spec
  """

  alias OpenApiSpex.Schema

  alias WandaWeb.Schemas.V1.Operation.{
    OperationTarget,
    StepReport
  }

  require Wanda.Operations.Enums.Result, as: Result
  require Wanda.Operations.Enums.Status, as: Status

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "OperationResponse",
      description: "The representation of an operation, it may be a running or completed one",
      type: :object,
      additionalProperties: false,
      properties: %{
        operation_id: %Schema{type: :string, format: :uuid, description: "Operation ID"},
        group_id: %Schema{type: :string, format: :uuid, description: "Group ID"},
        status: %Schema{
          type: :string,
          enum: Status.values(),
          description: "The status of the current operation"
        },
        result: %Schema{
          type: :string,
          nullable: true,
          enum: Result.values(),
          description: "Aggregated result of the operation, unknown for running ones"
        },
        name: %Schema{type: :string, description: "Operation name"},
        description: %Schema{type: :string, description: "Operation description"},
        operation: %Schema{type: :string, description: "Executed operation"},
        targets: %Schema{type: :array, items: OperationTarget},
        agent_reports: %Schema{type: :array, nullable: true, items: StepReport},
        started_at: %Schema{
          type: :string,
          format: :"date-time",
          description: "Operation start time"
        },
        updated_at: %Schema{
          type: :string,
          format: :"date-time",
          description: "Operation last update time"
        },
        completed_at: %Schema{
          type: :string,
          nullable: true,
          format: :"date-time",
          description: "Operation completion time"
        }
      },
      example: %{
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
    },
    struct?: false
  )
end

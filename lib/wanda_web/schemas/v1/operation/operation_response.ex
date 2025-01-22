defmodule WandaWeb.Schemas.V1.Operation.OperationResponse do
  @moduledoc """
  Operation item response API spec
  """

  alias OpenApiSpex.Schema

  alias WandaWeb.Schemas.V1.Operation.{
    StepReport,
    OperationTarget
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
      }
    },
    struct?: false
  )
end

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
      title: "OperationResponseV1",
      description:
        "Represents the details of an operation, including its status, timing, results, and associated targets. Can be running or completed.",
      type: :object,
      additionalProperties: false,
      properties: %{
        operation_id: %Schema{
          type: :string,
          format: :uuid,
          description: "The unique identifier of the operation."
        },
        group_id: %Schema{
          type: :string,
          format: :uuid,
          description: "The unique identifier of the group associated with the operation."
        },
        status: %Schema{
          type: :string,
          enum: Status.values(),
          description:
            "The current status of the operation, indicating its progress or completion state."
        },
        result: %Schema{
          type: :string,
          nullable: true,
          enum: Result.values(),
          description:
            "The aggregated result of the operation, summarizing the overall outcome. Unknown for running operations."
        },
        name: %Schema{type: :string, description: "The name of the operation being performed."},
        description: %Schema{
          type: :string,
          description:
            "A description of the operation, outlining its purpose and expected behavior."
        },
        operation: %Schema{
          type: :string,
          description: "The type of operation executed, specifying the action performed."
        },
        targets: %Schema{
          type: :array,
          items: OperationTarget,
          description: "The list of targets involved in the operation."
        },
        agent_reports: %Schema{
          type: :array,
          nullable: true,
          items: StepReport,
          description:
            "A list of reports from agents involved in the operation, providing detailed outcome information."
        },
        started_at: %Schema{
          type: :string,
          format: :"date-time",
          description: "The timestamp indicating when the operation started."
        },
        updated_at: %Schema{
          type: :string,
          format: :"date-time",
          description: "The timestamp indicating when the operation was last updated."
        },
        completed_at: %Schema{
          type: :string,
          nullable: true,
          format: :"date-time",
          description: "The timestamp indicating when the operation was completed, if applicable."
        }
      },
      example: %{
        operation_id: "985edb19-cb1d-463e-81c2-53a4fa85d1fa",
        group_id: "353fd789-d8ae-4a1b-a9f9-3919bd773e79",
        status: "completed",
        result: "updated",
        name: "Test operation",
        description: "A test operation.",
        operation: "testoperation@v1",
        targets: [
          %{
            agent_id: "a1b2c3d4-e5f6-7890-abcd-1234567890ab",
            arguments: %{"arg" => "test_value"}
          }
        ],
        agent_reports: [
          %{
            name: "First step",
            operator: "test@v1",
            predicate: "*",
            timeout: 60,
            agents: [
              %{
                agent_id: "a1b2c3d4-e5f6-7890-abcd-1234567890ab",
                result: "updated",
                diff: %{before: "old", after: "new"},
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

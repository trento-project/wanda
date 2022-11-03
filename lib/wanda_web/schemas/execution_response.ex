defmodule WandaWeb.Schemas.ExecutionResponse do
  @moduledoc """
  Execution item response API spec
  """

  require OpenApiSpex

  alias OpenApiSpex.Schema

  alias WandaWeb.Schemas.ExecutionResponse.CheckResult

  OpenApiSpex.schema(%{
    title: "ExecutionResponse",
    description: "The representation of an execution, it may be a running or completed one",
    type: :object,
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
      :timeout,
      :check_results
    ]
  })
end

defmodule WandaWeb.Schemas.V2.Execution.ExecutionResponse do
  @moduledoc """
  Execution item response API spec
  """

  alias OpenApiSpex.Schema

  alias WandaWeb.Schemas.V1.Execution.Target

  alias WandaWeb.Schemas.V2.Execution.CheckResult

  require OpenApiSpex

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
    ]
  })
end

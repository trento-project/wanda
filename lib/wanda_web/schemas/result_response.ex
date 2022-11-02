defmodule WandaWeb.Schemas.ResultResponse do
  @moduledoc nil

  require OpenApiSpex

  alias OpenApiSpex.Schema

  alias WandaWeb.Schemas.ResultResponse.CheckResult

  OpenApiSpex.schema(%{
    title: "ResultResponse",
    description: "The result of an execution",
    type: :object,
    properties: %{
      execution_id: %Schema{type: :string, format: :uuid, description: "Execution ID"},
      group_id: %Schema{type: :string, format: :uuid, description: "Group ID"},
      started_at: %Schema{type: :string, format: :"date-time", description: "Inserted at"},
      result: %Schema{
        type: :string,
        enum: ["passing", "warning", "critical"],
        description: "Aggregated result of the execution"
      },
      timeout: %Schema{
        type: :array,
        items: %Schema{type: :string, format: :uuid, description: "Agent ID"},
        description: "Timed out agents"
      },
      check_results: %Schema{type: :array, items: CheckResult}
    },
    required: [:execution_id, :group_id, :started_at, :result, :timeout]
  })
end

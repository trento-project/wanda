defmodule WandaWeb.Schemas.V1.Operation.AgentReport do
  @moduledoc false

  alias OpenApiSpex.Schema

  require Wanda.Operations.Enums.Result, as: Result

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "AgentReport",
      description: "Individual agent report of an operation",
      type: :object,
      additionalProperties: false,
      properties: %{
        agent_id: %Schema{type: :string, format: :uuid, description: "Agent ID"},
        result: %Schema{type: :string, enum: Result.values()}
      },
      required: [:agent_id, :result]
    },
    struct?: false
  )
end

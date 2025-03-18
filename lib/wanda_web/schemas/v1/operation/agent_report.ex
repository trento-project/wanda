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
        result: %Schema{type: :string, enum: Result.values()},
        diff: %Schema{
          type: :object,
          additionalProperties: false,
          nullable: true,
          properties: %{
            before: %Schema{description: "The state before applying the operation"},
            after: %Schema{description: "The state after applying the operation"}
          },
          description: "The operation before/after difference",
          required: [:before, :after]
        },
        error_message: %Schema{
          type: :string,
          nullable: true,
          description: "Error message in case of a failed operation"
        }
      },
      required: [:agent_id, :result, :diff, :error_message]
    },
    struct?: false
  )
end

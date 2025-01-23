defmodule WandaWeb.Schemas.V1.Operation.OperationTarget do
  @moduledoc false

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "OperationTarget",
      description: "Target where operations are executed",
      type: :object,
      additionalProperties: false,
      properties: %{
        agent_id: %Schema{type: :string, format: :uuid, description: "Agent ID"},
        arguments: %Schema{
          type: :object,
          description: "Arguments map",
          additionalProperties: %Schema{
            oneOf: [
              %Schema{type: :string},
              %Schema{type: :integer},
              %Schema{type: :boolean}
            ]
          }
        }
      },
      required: [:agent_id, :arguments]
    },
    struct?: false
  )
end

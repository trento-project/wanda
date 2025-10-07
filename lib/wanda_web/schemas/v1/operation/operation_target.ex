defmodule WandaWeb.Schemas.V1.Operation.OperationTarget do
  @moduledoc false

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "OperationTargetV1",
      description:
        "Represents the target where operations are executed, including agent identification and arguments for execution.",
      type: :object,
      additionalProperties: false,
      properties: %{
        agent_id: %Schema{
          type: :string,
          format: :uuid,
          description: "The unique identifier of the agent where the operation is executed."
        },
        arguments: %Schema{
          type: :object,
          description:
            "A map of arguments provided for the operation execution, allowing for flexible configuration.",
          additionalProperties: %Schema{
            oneOf: [
              %Schema{type: :string},
              %Schema{type: :integer},
              %Schema{type: :boolean}
            ]
          }
        }
      },
      required: [:agent_id, :arguments],
      example: %{
        agent_id: "a1b2c3d4-e5f6-7890-abcd-1234567890ab",
        arguments: %{"package" => "nginx", "version" => "1.18.0"}
      }
    },
    struct?: false
  )
end

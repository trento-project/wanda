defmodule WandaWeb.Schemas.V1.Execution.Target do
  @moduledoc false

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "Target",
      description:
        "Represents the target where execution facts are gathered, including agent and check associations.",
      type: :object,
      additionalProperties: false,
      properties: %{
        agent_id: %Schema{
          type: :string,
          format: :uuid,
          description:
            "The unique identifier of the agent for which facts are gathered during execution."
        },
        checks: %Schema{
          type: :array,
          items: %Schema{
            type: :string,
            description:
              "The unique identifier of the check associated with the target agent for execution."
          }
        }
      },
      required: [:agent_id, :checks],
      example: %{
        agent_id: "a1b2c3d4-e5f6-7890-abcd-1234567890ab",
        checks: ["156F64"]
      }
    },
    struct?: false
  )
end

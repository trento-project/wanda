defmodule WandaWeb.Schemas.V1.Execution.AgentCheckError do
  @moduledoc false

  alias OpenApiSpex.Schema

  alias WandaWeb.Schemas.V1.Execution.{Fact, FactError}

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "AgentCheckError",
      description:
        "An error describing that some of the facts could not be gathered on a specific agent eg. gathering failure or timeout",
      type: :object,
      additionalProperties: false,
      properties: %{
        agent_id: %Schema{type: :string, format: :uuid, description: "Agent ID"},
        facts: %Schema{
          description: "Facts gathered, possibly with errors, from the target",
          type: :array,
          items: %Schema{
            oneOf: [
              Fact,
              FactError
            ]
          },
          nullable: true
        },
        type: %Schema{type: :string, description: "Error type"},
        message: %Schema{type: :string, description: "Error message"}
      },
      required: [:agent_id, :type, :message],
      example: %{
        agent_id: "a1b2c3d4-e5f6-7890-abcd-1234567890ab",
        facts: [
          %{
            check_id: "SLES-HA-1",
            name: "node_count",
            value: 3
          },
          %{
            check_id: "SLES-HA-1",
            name: "node_count",
            type: "gathering_error",
            message: "Timeout"
          }
        ],
        type: "gathering_error",
        message: "Timeout while gathering facts"
      }
    },
    struct?: false
  )
end

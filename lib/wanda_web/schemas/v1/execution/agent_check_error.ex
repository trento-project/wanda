defmodule WandaWeb.Schemas.V1.Execution.AgentCheckError do
  @moduledoc false

  alias OpenApiSpex.Schema

  alias WandaWeb.Schemas.V1.Execution.{Fact, FactError}

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "AgentCheckError",
      description:
        "Indicates that some facts could not be gathered on a specific agent due to issues such as gathering failure or timeout. This error provides context for troubleshooting agent data collection problems.",
      type: :object,
      additionalProperties: false,
      properties: %{
        agent_id: %Schema{
          type: :string,
          format: :uuid,
          description: "The unique identifier of the agent involved in the error."
        },
        facts: %Schema{
          description:
            "Facts gathered from the target agent, which may include errors encountered during the data collection process.",
          type: :array,
          items: %Schema{
            oneOf: [
              Fact,
              FactError
            ]
          },
          nullable: true
        },
        type: %Schema{
          type: :string,
          description: "The type of error encountered during fact gathering on the agent."
        },
        message: %Schema{
          type: :string,
          description:
            "A detailed message describing the error encountered during fact gathering on the agent."
        }
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

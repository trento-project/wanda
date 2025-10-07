defmodule WandaWeb.Schemas.V1.Operation.AgentReport do
  @moduledoc false

  alias OpenApiSpex.Schema

  require Wanda.Operations.Enums.Result, as: Result

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "AgentReportV1",
      description:
        "Represents an individual agent report of an operation, including agent identification, result, state differences, and error messages.",
      type: :object,
      additionalProperties: false,
      properties: %{
        agent_id: %Schema{
          type: :string,
          format: :uuid,
          description: "The unique identifier of the agent for which the report is generated."
        },
        result: %Schema{type: :string, enum: Result.values()},
        diff: %Schema{
          type: :object,
          additionalProperties: false,
          nullable: true,
          properties: %{
            before: %Schema{
              type: :string,
              description:
                "The state of the agent before applying the operation, providing context for the change."
            },
            after: %Schema{
              type: :string,
              description:
                "The state of the agent after applying the operation, showing the result of the change."
            }
          },
          description:
            "The difference in the agent's state before and after the operation, useful for tracking changes.",
          required: [:before, :after]
        },
        error_message: %Schema{
          type: :string,
          nullable: true,
          description:
            "A detailed error message in case the operation failed for the agent, providing troubleshooting information."
        }
      },
      required: [:agent_id, :result, :diff, :error_message],
      example: %{
        agent_id: "a1b2c3d4-e5f6-7890-abcd-1234567890ab",
        result: "updated",
        diff: %{before: "absent", after: "present"},
        error_message: ""
      }
    },
    struct?: false
  )
end

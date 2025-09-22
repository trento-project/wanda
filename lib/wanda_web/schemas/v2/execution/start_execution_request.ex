defmodule WandaWeb.Schemas.V2.Execution.StartExecutionRequest do
  @moduledoc """
  The request to be sent to start an execution.
  """

  alias OpenApiSpex.Schema
  alias WandaWeb.Schemas.V2.Env

  require OpenApiSpex

  defmodule Target do
    @moduledoc false

    OpenApiSpex.schema(
      %{
        title: "Target",
        description:
          "This object represents the agent where facts will be gathered for the execution process.",
        type: :object,
        additionalProperties: false,
        properties: %{
          agent_id: %Schema{
            type: :string,
            format: :uuid,
            description: "A unique identifier for the agent involved in the execution process."
          },
          checks: %Schema{
            title: "ChecksSelection",
            description:
              "A list of checks that will be executed for this target during the current execution.",
            type: :array,
            items: %Schema{type: :string}
          }
        },
        required: [:agent_id, :checks]
      },
      struct?: false
    )
  end

  OpenApiSpex.schema(
    %{
      title: "StartExecutionRequest",
      description:
        "This schema defines the context and parameters required to start a check execution.",
      type: :object,
      additionalProperties: false,
      properties: %{
        execution_id: %Schema{
          type: :string,
          format: :uuid,
          description: "A unique identifier for the execution instance."
        },
        group_id: %Schema{
          type: :string,
          format: :uuid,
          description:
            "A unique identifier for the group associated with this execution instance."
        },
        targets: %Schema{
          description: "An array of agents that will participate in the execution process.",
          type: :array,
          items: Target
        },
        target_type: %Schema{
          type: :string,
          description: "Specifies the type of target for the execution process."
        },
        env: Env
      },
      required: [:execution_id, :group_id, :targets],
      example: %{
        execution_id: "e1a2b3c4-d5f6-7890-abcd-1234567890ab",
        group_id: "353fd789-d8ae-4a1b-a9f9-3919bd773e79",
        targets: [
          %{agent_id: "a1b2c3d4-e5f6-7890-abcd-1234567890ab", checks: ["156F64"]}
        ],
        env: %{"VAR1" => "value1"}
      }
    },
    struct?: false
  )
end

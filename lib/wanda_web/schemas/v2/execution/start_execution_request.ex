defmodule WandaWeb.Schemas.V2.Execution.StartExecutionRequest do
  @moduledoc """
  The request to be sent to start an execution
  """

  alias OpenApiSpex.Schema
  alias WandaWeb.Schemas.V2.Env

  require OpenApiSpex

  defmodule Target do
    @moduledoc false

    OpenApiSpex.schema(
      %{
        title: "Target",
        description: "Target Agent on which facts gathering should happen",
        type: :object,
        additionalProperties: false,
        properties: %{
          agent_id: %Schema{
            type: :string,
            format: :uuid,
            description: "Target Agent identifier"
          },
          checks: %Schema{
            title: "ChecksSelection",
            description:
              "Selection of checks to be executed on this specific target, in current execution",
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
      description: "Context to run a Check Execution",
      type: :object,
      additionalProperties: false,
      properties: %{
        execution_id: %Schema{type: :string, format: :uuid, description: "Execution identifier"},
        group_id: %Schema{type: :string, format: :uuid, description: "Group Execution identifier"},
        targets: %Schema{
          description: "List of target agents for the execution.",
          type: :array,
          items: Target
        },
        target_type: %Schema{type: :string, description: "Execution target type"},
        env: Env
      },
      required: [:execution_id, :group_id, :targets],
      example: %{
        execution_id: "e1a2b3c4-d5f6-7890-abcd-1234567890ab",
        group_id: "g1a2b3c4-d5f6-7890-abcd-1234567890ab",
        targets: [
          %{agent_id: "a1b2c3d4-e5f6-7890-abcd-1234567890ab", checks: ["SLES-HA-1"]}
        ],
        env: %{"VAR1" => "value1"}
      }
    },
    struct?: false
  )
end

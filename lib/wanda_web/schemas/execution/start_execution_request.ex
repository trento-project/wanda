defmodule WandaWeb.Schemas.StartExecutionRequest do
  @moduledoc """
  The request to be sent to start an execution
  """

  require OpenApiSpex

  alias OpenApiSpex.Schema

  defmodule Target do
    @moduledoc false

    OpenApiSpex.schema(%{
      title: "Target",
      description: "Target Agent on which facts gathering should happen",
      type: :object,
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
    })
  end

  defmodule Env do
    @moduledoc false

    OpenApiSpex.schema(%{
      title: "ExecutionEnv",
      description: "Contextual Environment for the current execution",
      type: :object,
      additionalProperties: %Schema{
        oneOf: [
          %Schema{type: :string},
          %Schema{type: :int}
        ]
      }
    })
  end

  OpenApiSpex.schema(%{
    title: "StartExecutionRequest",
    description: "Context to run a Check Execution",
    type: :object,
    properties: %{
      execution_id: %Schema{type: :string, format: :uuid, description: "Execution identifier"},
      group_id: %Schema{type: :string, format: :uuid, description: "Group Execution identifier"},
      targets: %Schema{
        title: "Targets",
        type: :array,
        items: Target
      },
      env: Env
    },
    required: [:execution_id, :group_id, :targets, :env]
  })
end

defmodule WandaWeb.Schemas.V1.Execution.AgentCheckError do
  @moduledoc false

  alias OpenApiSpex.Schema

  alias WandaWeb.Schemas.V1.Execution.{Fact, FactError}

  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "AgentCheckError",
    description:
      "An error describing that some of the facts could not be gathered on a specific agent eg. gathering failure or timeout",
    type: :object,
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
    required: [:agent_id, :type, :message]
  })
end

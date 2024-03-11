defmodule WandaWeb.Schemas.V1.Execution.Target do
  @moduledoc false

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "Target",
    description: "Target where execution facts are gathered",
    type: :object,
    additionalProperties: false,
    properties: %{
      agent_id: %Schema{type: :string, format: :uuid, description: "Agent ID"},
      checks: %Schema{
        type: :array,
        items: %Schema{type: :string, description: "Check ID"}
      }
    },
    required: [:agent_id, :checks]
  })
end

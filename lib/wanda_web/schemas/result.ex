defmodule WandaWeb.Schemas.Result do
  @moduledoc nil

  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Result",
    description: "The result of an execution",
    type: :object,
    properties: %{
      execution_id: %Schema{type: :string, description: "Execution ID"},
      group_id: %Schema{type: :string, description: "Group ID"},
      payload: %Schema{type: :object, description: "Payload of the check execution"}
    },
    required: [:execution_id, :group_id, :payload]
  })
end

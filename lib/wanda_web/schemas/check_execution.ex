defmodule WandaWeb.Schemas.CheckExecution do
  @moduledoc """
  Check execution API spec
  """

  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "CheckExecution",
    description: "A single execution of checks",
    type: :object,
    properties: %{
      execution_id: %Schema{type: :string, description: "Execution ID"},
      group_id: %Schema{type: :string, description: "Group ID"},
      payload: %Schema{type: :object, description: "Payload of the check execution"}
    }
  })
end

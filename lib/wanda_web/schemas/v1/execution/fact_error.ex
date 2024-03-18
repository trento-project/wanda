defmodule WandaWeb.Schemas.V1.Execution.FactError do
  @moduledoc false

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "FactError",
    description: "An error describing that a fact could not be gathered",
    type: :object,
    additionalProperties: false,
    properties: %{
      check_id: %Schema{type: :string, description: "Check ID"},
      name: %Schema{type: :string, description: "Fact name"},
      type: %Schema{type: :string, description: "Error type"},
      message: %Schema{type: :string, description: "Error message"}
    },
    required: [:check_id, :name, :type, :message]
  })
end

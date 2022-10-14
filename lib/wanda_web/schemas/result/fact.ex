defmodule WandaWeb.Schemas.ResultResponse.Fact do
  @moduledoc false

  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Fact",
    description: "The result of a check",
    type: :object,
    properties: %{
      check_id: %Schema{type: :string, description: "Check ID"},
      name: %Schema{type: :string, description: "Name"},
      value: %Schema{
        oneOf: [%Schema{type: :string}, %Schema{type: :number}, %Schema{type: :boolean}],
        description: "Value"
      }
    },
    required: [:check_id, :name, :value]
  })
end

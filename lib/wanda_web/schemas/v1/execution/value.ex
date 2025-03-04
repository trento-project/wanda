defmodule WandaWeb.Schemas.V1.Execution.Value do
  @moduledoc false

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "Value",
      description: "A Value used in the expectations evaluation",
      type: :object,
      additionalProperties: false,
      properties: %{
        name: %Schema{type: :string, description: "Name"},
        value: %Schema{
          oneOf: [%Schema{type: :string}, %Schema{type: :number}, %Schema{type: :boolean}],
          description: "Value"
        },
        customized: %Schema{type: :boolean, description: "Whether the value has been customized"}
      },
      required: [:check_id, :name, :value]
    },
    struct?: false
  )
end

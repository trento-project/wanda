defmodule WandaWeb.Schemas.V1.Execution.Fact do
  @moduledoc false

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "Fact",
      description: "The result of a check",
      type: :object,
      additionalProperties: false,
      properties: %{
        check_id: %Schema{type: :string, description: "Check ID"},
        name: %Schema{type: :string, description: "Name"},
        value: %Schema{
          oneOf: [
            %Schema{type: :string},
            %Schema{type: :number},
            %Schema{type: :boolean},
            %Schema{type: :array},
            %Schema{type: :object}
          ],
          description: "Value"
        }
      },
      required: [:check_id, :name, :value]
    },
    struct?: false
  )
end

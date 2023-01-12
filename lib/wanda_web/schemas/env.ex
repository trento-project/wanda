defmodule WandaWeb.Schemas.Env do
  @moduledoc false

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "ExecutionEnv",
      description: "Contextual Environment for the current execution",
      type: :object,
      additionalProperties: %Schema{
        oneOf: [
          %Schema{type: :string},
          %Schema{type: :integer},
          %Schema{type: :boolean},
          %Schema{type: :array, items: __MODULE__}
        ]
      }
    },
    struct?: false
  )
end

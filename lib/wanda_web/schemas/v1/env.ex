defmodule WandaWeb.Schemas.V1.Env do
  @moduledoc false

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "ExecutionEnv",
      deprecated: true,
      description:
        "Defines the contextual environment settings used during the current execution, allowing for flexible configuration.",
      type: :object,
      additionalProperties: %Schema{
        oneOf: [
          %Schema{type: :string},
          %Schema{type: :integer},
          %Schema{type: :boolean},
          %Schema{type: :array, items: __MODULE__}
        ]
      },
      example: %{
        "VAR1" => "value1",
        "MAX_RETRIES" => 3,
        "DEBUG" => true
      }
    },
    struct?: false
  )
end

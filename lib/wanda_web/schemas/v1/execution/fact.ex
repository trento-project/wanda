defmodule WandaWeb.Schemas.V1.Execution.Fact do
  @moduledoc false

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "Fact",
      description:
        "Represents a fact gathered during execution, including its check association and observed value.",
      type: :object,
      additionalProperties: false,
      properties: %{
        check_id: %Schema{
          type: :string,
          description:
            "The unique identifier of the check that produced this fact during execution."
        },
        name: %Schema{
          type: :string,
          description:
            "The name of the fact representing the observed property or metric gathered during execution."
        },
        value: %Schema{
          oneOf: [
            %Schema{type: :string},
            %Schema{type: :number},
            %Schema{type: :boolean},
            %Schema{type: :array, items: %Schema{type: :string}},
            %Schema{type: :object}
          ],
          description:
            "The value of the fact as observed during execution, which may be a string, integer, boolean, or array."
        }
      },
      required: [:check_id, :name, :value],
      example: %{
        check_id: "SLES-HA-1",
        name: "node_count",
        value: 3
      }
    },
    struct?: false
  )
end

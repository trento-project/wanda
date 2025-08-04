defmodule WandaWeb.Schemas.V1.ChecksSelection.NotCustomizedCheckValue do
  @moduledoc """
  A Check Value that has not been customized.

  It could be customizable or not.
  """

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "NotCustomizedCheckValue",
      description: "A check value that is not customized",
      type: :object,
      additionalProperties: false,
      example: %{
        name: "threshold",
        default_value: 10,
        customizable: true
      },
      properties: %{
        name: %Schema{type: :string, description: "Value name"},
        default_value: %Schema{
          oneOf: [
            %Schema{type: :string},
            %Schema{anyOf: [%Schema{type: :integer}, %Schema{type: :number}]},
            %Schema{type: :boolean}
          ],
          description:
            "Original value as defined by specification. Resolved based on the environment. Absent if value is not customizable."
        },
        customizable: %Schema{
          type: :boolean,
          description: "Whether the check is customizable or not"
        }
      },
      required: [:name, :customizable]
    },
    struct?: false
  )
end

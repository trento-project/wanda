defmodule WandaWeb.Schemas.V1.ChecksSelection.NotCustomizedCheckValue do
  @moduledoc """
  Individual Customized Check Value
  """

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "NotCustomizedCheckValue",
      description: "A check value that is not customized",
      type: :object,
      additionalProperties: false,
      properties: %{
        name: %Schema{type: :string, description: "Value name"},
        current_value: %Schema{
          oneOf: [
            %Schema{type: :string},
            %Schema{anyOf: [%Schema{type: :integer}, %Schema{type: :number}]},
            %Schema{type: :boolean}
          ],
          description:
            "Value that is currently being used for the check based on the environment. Absent if value is not customizable."
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

defmodule WandaWeb.Schemas.V1.ChecksSelection.NotCustomizedCheckValue do
  @moduledoc """
  A Check Value that has not been customized.

  It could be customizable or not.
  """

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "NotCustomizedCheckValueV1",
      description:
        "Represents a check value that has not been customized, including its name, default value, and customization status.",
      type: :object,
      additionalProperties: false,
      example: %{
        name: "threshold",
        default_value: 10,
        customizable: true
      },
      properties: %{
        name: %Schema{
          type: :string,
          description: "The name of the check value that has not been customized."
        },
        default_value: %Schema{
          oneOf: [
            %Schema{type: :string},
            %Schema{anyOf: [%Schema{type: :integer}, %Schema{type: :number}]},
            %Schema{type: :boolean}
          ],
          description:
            "The original value as defined by specification, resolved based on the environment. Absent if value is not customizable."
        },
        customizable: %Schema{
          type: :boolean,
          description:
            "Indicates whether the check value can be customized for execution, allowing for tailored validation."
        }
      },
      required: [:name, :customizable]
    },
    struct?: false
  )
end

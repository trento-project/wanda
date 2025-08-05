defmodule WandaWeb.Schemas.V1.Execution.Value do
  @moduledoc false

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "Value",
      description:
        "Represents a value used in the expectations evaluation, including its name, check association, and customization status.",
      type: :object,
      additionalProperties: false,
      properties: %{
        name: %Schema{
          type: :string,
          description: "The name of the value used in the expectations evaluation."
        },
        check_id: %Schema{
          type: :string,
          description: "The unique identifier of the check associated with the value."
        },
        value: %Schema{
          oneOf: [%Schema{type: :string}, %Schema{type: :number}, %Schema{type: :boolean}],
          description:
            "The value used in the expectations evaluation, which may be a string, integer, boolean, or array."
        },
        customized: %Schema{
          type: :boolean,
          description:
            "Indicates whether the value has been customized for the expectations evaluation."
        }
      },
      required: [:check_id, :name, :value],
      example: %{
        name: "fencing_configured",
        check_id: "SLES-HA-1",
        value: true,
        customized: false
      }
    },
    struct?: false
  )
end

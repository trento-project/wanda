defmodule WandaWeb.Schemas.V1.Operation.StepReport do
  @moduledoc false

  alias OpenApiSpex.Schema

  alias WandaWeb.Schemas.V1.Operation.AgentReport

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "StepReport",
      description:
        "Represents a report for a single step in an operation, including step details and agent outcomes.",
      type: :object,
      additionalProperties: false,
      properties: %{
        name: %Schema{
          type: :string,
          description: "The name of the operation step being reported."
        },
        operator: %Schema{
          type: :string,
          description:
            "The operator used in the operation step, specifying the comparison or action performed."
        },
        predicate: %Schema{
          type: :string,
          description:
            "The predicate evaluated in the operation step, defining the condition for success."
        },
        timeout: %Schema{
          type: :integer,
          description:
            "The timeout value for the operation step, specifying the maximum allowed duration in seconds."
        },
        agents: %Schema{type: :array, items: AgentReport}
      },
      required: [:name, :operator, :predicate, :timeout, :agents],
      example: %{
        name: "install_package",
        operator: "equals",
        predicate: "package_installed == true",
        timeout: 60,
        agents: [
          %{
            agent_id: "a1b2c3d4-e5f6-7890-abcd-1234567890ab",
            result: "updated",
            diff: %{before: "absent", after: "present"},
            error_message: ""
          }
        ]
      }
    },
    struct?: false
  )
end

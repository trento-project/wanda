defmodule WandaWeb.Schemas.V1.Operation.StepReport do
  @moduledoc false

  alias OpenApiSpex.Schema

  alias WandaWeb.Schemas.V1.Operation.AgentReport

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "StepReport",
      description: "Operation step report",
      type: :object,
      additionalProperties: false,
      properties: %{
        name: %Schema{type: :string, description: "Operation step name"},
        operator: %Schema{type: :string, description: "Operation step operator"},
        predicate: %Schema{type: :string, description: "Operation step predicate"},
        timeout: %Schema{type: :integer, description: "Operation step timeout"},
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

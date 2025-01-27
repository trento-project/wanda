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
        name: %Schema{type: :string, description: "Operation step tname"},
        operator: %Schema{type: :string, description: "Operation step operator"},
        predicate: %Schema{type: :string, description: "Operation step predicate"},
        timeout: %Schema{type: :integer, description: "Operation step timeout"},
        agents: %Schema{type: :array, items: AgentReport}
      },
      required: [:name, :operator, :predicate, :timeout, :agents]
    },
    struct?: false
  )
end

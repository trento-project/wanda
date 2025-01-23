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
        step_number: %Schema{type: :integer, description: "Step number"},
        agents: %Schema{type: :array, items: AgentReport}
      },
      required: [:step_number, :agents]
    },
    struct?: false
  )
end

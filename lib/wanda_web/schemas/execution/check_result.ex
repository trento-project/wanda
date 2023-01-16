defmodule WandaWeb.Schemas.ExecutionResponse.CheckResult do
  @moduledoc false

  alias OpenApiSpex.Schema

  alias WandaWeb.Schemas.ExecutionResponse.{AgentCheckError, AgentCheckResult, ExpectationResult}

  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "CheckResult",
    description: "The result of a check",
    type: :object,
    properties: %{
      check_id: %Schema{type: :string, description: "Check ID"},
      expectation_results: %Schema{type: :array, items: ExpectationResult},
      agents_check_results: %Schema{
        type: :array,
        items: %Schema{
          oneOf: [
            AgentCheckResult,
            AgentCheckError
          ]
        }
      },
      result: %Schema{
        type: :string,
        enum: ["passing", "warning", "critical"],
        description: "Result of the check"
      }
    },
    required: [:check_id, :expectation_results, :agents_check_results, :result]
  })
end

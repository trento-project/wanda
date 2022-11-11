defmodule WandaWeb.Schemas.AcceptedExecutionResponse do
  @moduledoc """
  Minimal information about an Execution accepted by the system,
  it carries the same identifiers provided by the consumer that triggered the request.

  These identifiers may be used to query the APIs about the state of an execution.
  """

  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "AcceptedExecution",
    description:
      "Identifiers of the Accepted Execution, status needs to be checks at appropriate API",
    type: :object,
    properties: %{
      execution_id: %Schema{type: :string, format: :uuid},
      group_id: %Schema{type: :string, format: :uuid}
    }
  })
end

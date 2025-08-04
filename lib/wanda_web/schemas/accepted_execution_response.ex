defmodule WandaWeb.Schemas.AcceptedExecutionResponse do
  @moduledoc """
  Minimal information about an Execution accepted by the system,
  it carries the same identifiers provided by the consumer that requested the execution to start.

  These identifiers may be used to query the APIs about the state of an execution.
  """

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "AcceptedExecutionResponse",
      description: "Identifiers of the recently accepted execution",
      type: :object,
      additionalProperties: false,
      properties: %{
        execution_id: %Schema{type: :string, format: :uuid},
        group_id: %Schema{type: :string, format: :uuid}
      },
      example: %{
        execution_id: "e1a2b3c4-d5f6-7890-abcd-1234567890ab",
        group_id: "g1a2b3c4-d5f6-7890-abcd-1234567890ab"
      }
    },
    struct?: false
  )
end

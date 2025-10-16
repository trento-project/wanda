defmodule WandaWeb.Schemas.V1.AcceptedExecutionResponse do
  @moduledoc """
  Minimal information about an Execution accepted by the system,
  it carries the same identifiers provided by the consumer that requested the execution to start.

  These identifiers may be used to query the APIs about the state of an execution.
  """

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(
    %{
      title: "AcceptedExecutionResponseV1",
      description:
        "This response contains the identifiers for an execution that was recently accepted by the system. These identifiers can be used to query the execution status later.",
      type: :object,
      additionalProperties: false,
      properties: %{
        execution_id: %Schema{type: :string, format: :uuid, example: "e1a2b3c4-d5f6-7890-abcd-1234567890ab"},
        group_id: %Schema{type: :string, format: :uuid, example: "353fd789-d8ae-4a1b-a9f9-3919bd773e79"}
      },
      example: %{
        execution_id: "e1a2b3c4-d5f6-7890-abcd-1234567890ab",
        group_id: "353fd789-d8ae-4a1b-a9f9-3919bd773e79"
      }
    },
    struct?: false
  )
end

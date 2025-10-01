defmodule WandaWeb.Schemas.V1.Execution.StartExecutionRequest do
  @moduledoc """
  The request to be sent to start an execution.
  """

  alias OpenApiSpex.Schema
  alias WandaWeb.Schemas.V1.Env

  require OpenApiSpex

  defmodule Target do
    @moduledoc false

    OpenApiSpex.schema(
      %{
        title: "Target",
        deprecated: true,
        description:
          "Specifies the target agent on which facts gathering should occur during execution.",
        type: :object,
        additionalProperties: false,
        properties: %{
          agent_id: %Schema{
            type: :string,
            format: :uuid,
            description:
              "The unique identifier of the target agent for fact gathering during execution.",
            example: "a1b2c3d4-e5f6-7890-abcd-1234567890ab"
          },
          checks: %Schema{
            title: "ChecksSelection",
            description:
              "A selection of checks to be executed on this specific target in the current execution, allowing for targeted validation.",
            type: :array,
            items: %Schema{type: :string},
            example: ["156F64"]
          }
        },
        required: [:agent_id, :checks]
      },
      struct?: false
    )
  end

  OpenApiSpex.schema(
    %{
      title: "StartExecutionRequest",
      deprecated: true,
      description:
        "Defines the context required to run a check execution, including execution and group identifiers, targets, and environment settings.",
      type: :object,
      additionalProperties: false,
      properties: %{
        execution_id: %Schema{
          type: :string,
          format: :uuid,
          description: "The unique identifier for the execution instance.",
          example: "e1a2b3c4-d5f6-7890-abcd-1234567890ab"
        },
        group_id: %Schema{
          type: :string,
          format: :uuid,
          description:
            "The unique identifier for the group associated with the execution instance.",
          example: "353fd789-d8ae-4a1b-a9f9-3919bd773e79"
        },
        targets: %Schema{
          description:
            "A list of target agents involved in the execution, each specified by their unique identifier.",
          type: :array,
          items: Target,
          example: [
            %{agent_id: "a1b2c3d4-e5f6-7890-abcd-1234567890ab", checks: ["156F64"]}
          ]
        },
        target_type: %Schema{
          type: :string,
          description:
            "The type of target for the execution, specifying the nature of the execution environment.",
          example: "host"
        },
        env: Env
      },
      required: [:execution_id, :group_id, :targets],
      example: %{
        execution_id: "e1a2b3c4-d5f6-7890-abcd-1234567890ab",
        group_id: "353fd789-d8ae-4a1b-a9f9-3919bd773e79",
        env: %{"VAR1" => "value1"},
        targets: [
          %{agent_id: "a1b2c3d4-e5f6-7890-abcd-1234567890ab", checks: ["156F64"]}
        ]
      }
    },
    struct?: false
  )
end

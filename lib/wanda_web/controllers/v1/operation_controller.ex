defmodule WandaWeb.V1.OperationController do
  use WandaWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias OpenApiSpex.Schema

  alias Wanda.Operations

  alias WandaWeb.Schemas.V1.{NotFound, UnprocessableEntity}

  alias WandaWeb.Schemas.V1.Operation.{
    ListOperationsResponse,
    OperationResponse
  }

  require Wanda.Operations.Enums.Status, as: Status

  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true
  action_fallback WandaWeb.FallbackController

  operation :index,
    summary: "List operations.",
    description:
      "Provides a paginated list of operations performed in the system, allowing for easy tracking and management.",
    tags: ["Operations Engine"],
    parameters: [
      group_id: [
        in: :query,
        description: "The unique identifier of the group to filter the operations list.",
        type: %Schema{
          type: :string,
          format: :uuid
        },
        example: "c1a2b3c4-d5e6-7890-abcd-ef1234567890"
      ],
      page: [
        in: :query,
        description: "Specify the page number to retrieve paginated results for operations.",
        type: :integer,
        example: 3
      ],
      items_per_page: [
        in: :query,
        description: "Set the number of items to be returned per page in the paginated results.",
        type: :integer,
        example: 20
      ],
      status: [
        in: :query,
        description: "Filter the operations by their status, using one of the allowed values.",
        type: %Schema{
          type: :string,
          enum: Status.values()
        }
      ]
    ],
    responses: [
      ok:
        {"A successful response containing a paginated list of operations.", "application/json",
         ListOperationsResponse},
      unprocessable_entity: UnprocessableEntity.response()
    ]

  def index(conn, params) do
    operations =
      params
      |> Operations.list_operations()
      |> Enum.map(&Operations.enrich_operation!(&1))

    render(conn, operations: operations)
  end

  operation :show,
    summary: "Get an operation by ID.",
    description:
      "Provides detailed information about a specific operation identified by its UUID.",
    tags: ["Operations Engine"],
    parameters: [
      id: [
        in: :path,
        description: "The unique identifier (UUID) of the operation to retrieve details for.",
        type: %Schema{
          type: :string,
          format: :uuid
        },
        example: "c1a2b3c4-d5e6-7890-abcd-ef1234567890"
      ]
    ],
    responses: [
      ok:
        {"A successful response containing details of the requested operation.",
         "application/json", OperationResponse},
      not_found: NotFound.response(),
      unprocessable_entity: UnprocessableEntity.response()
    ]

  def show(conn, %{id: operation_id}) do
    operation =
      operation_id
      |> Operations.get_operation!()
      |> Operations.enrich_operation!()

    render(conn, operation: operation)
  end
end

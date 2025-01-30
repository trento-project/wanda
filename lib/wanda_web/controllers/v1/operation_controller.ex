defmodule WandaWeb.V1.OperationController do
  use WandaWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias OpenApiSpex.Schema

  alias Wanda.Operations

  alias WandaWeb.Schemas.NotFound

  alias WandaWeb.Schemas.V1.Operation.{
    ListOperationsResponse,
    OperationResponse
  }

  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true
  action_fallback WandaWeb.FallbackController

  operation :index,
    summary: "List operations",
    parameters: [
      group_id: [
        in: :query,
        description: "Filter by group ID",
        type: %Schema{
          type: :string,
          format: :uuid
        },
        example: "00000000-0000-0000-0000-000000000001"
      ],
      page: [in: :query, description: "Page", type: :integer, example: 3],
      items_per_page: [in: :query, description: "Items per page", type: :integer, example: 20]
    ],
    responses: [
      ok: {"List operations response", "application/json", ListOperationsResponse},
      unprocessable_entity: OpenApiSpex.JsonErrorResponse.response()
    ]

  def index(conn, params) do
    operations =
      params
      |> Operations.list_operations()
      |> Enum.map(&Operations.enrich_operation!(&1))
      |> Enum.map(&Operations.compute_aborted(&1, DateTime.utc_now()))

    render(conn, operations: operations)
  end

  operation :show,
    summary: "Get an operation by ID",
    parameters: [
      id: [
        in: :path,
        description: "Operation ID",
        type: %Schema{
          type: :string,
          format: :uuid
        },
        example: "00000000-0000-0000-0000-000000000001"
      ]
    ],
    responses: [
      ok: {"Operation", "application/json", OperationResponse},
      not_found: NotFound.response(),
      unprocessable_entity: OpenApiSpex.JsonErrorResponse.response()
    ]

  def show(conn, %{id: operation_id}) do
    operation =
      operation_id
      |> Operations.get_operation!()
      |> Operations.enrich_operation!()
      |> Operations.compute_aborted(DateTime.utc_now())

    render(conn, operation: operation)
  end
end

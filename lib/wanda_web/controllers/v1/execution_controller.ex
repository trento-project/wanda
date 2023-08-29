defmodule WandaWeb.V1.ExecutionController do
  use WandaWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias OpenApiSpex.Schema

  alias Wanda.Executions
  alias Wanda.Executions.Target

  alias WandaWeb.Schemas.{
    AcceptedExecutionResponse,
    BadRequest,
    ExecutionResponse,
    ListExecutionsResponse,
    NotFound,
    StartExecutionRequest
  }

  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true
  action_fallback WandaWeb.FallbackController

  operation :index,
    summary: "List executions",
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
      ok: {"List executions response", "application/json", ListExecutionsResponse},
      unprocessable_entity: OpenApiSpex.JsonErrorResponse.response()
    ]

  def index(conn, params) do
    executions = Executions.list_executions(params)
    total_count = Executions.count_executions(params)

    render(conn, executions: executions, total_count: total_count)
  end

  operation :show,
    summary: "Get an execution by ID",
    parameters: [
      id: [
        in: :path,
        description: "Execution ID",
        type: %Schema{
          type: :string,
          format: :uuid
        },
        example: "00000000-0000-0000-0000-000000000001"
      ]
    ],
    responses: [
      ok: {"Execution", "application/json", ExecutionResponse},
      not_found: NotFound.response(),
      unprocessable_entity: OpenApiSpex.JsonErrorResponse.response()
    ]

  def show(conn, %{id: execution_id}) do
    execution = Executions.get_execution!(execution_id)

    render(conn, execution: execution)
  end

  operation :last,
    summary: "Get the last execution of a group",
    parameters: [
      id: [
        in: :path,
        description: "Group ID",
        type: %Schema{
          type: :string,
          format: :uuid
        },
        example: "00000000-0000-0000-0000-000000000001"
      ]
    ],
    responses: [
      ok: {"Execution", "application/json", ExecutionResponse},
      not_found: NotFound.response(),
      unprocessable_entity: OpenApiSpex.JsonErrorResponse.response()
    ]

  def last(conn, %{id: group_id}) do
    execution = Executions.get_last_execution_by_group_id!(group_id)

    render(conn, :show, execution: execution)
  end

  operation :start,
    summary: "Start a Checks Execution",
    description: "Start a Checks Execution on the target infrastructure",
    request_body: {"Execution Context", "application/json", StartExecutionRequest},
    responses: [
      accepted: {"Accepted Execution Response", "application/json", AcceptedExecutionResponse},
      bad_request: BadRequest.response(),
      unprocessable_entity: OpenApiSpex.JsonErrorResponse.response()
    ]

  def start(
        conn,
        _params
      ) do
    %{
      execution_id: execution_id,
      group_id: group_id,
      targets: targets,
      env: env
    } = body_params = Map.get(conn, :body_params)

    target_type = Map.get(body_params, :target_type)

    with :ok <-
           execution_server_impl().start_execution(
             execution_id,
             group_id,
             Target.map_targets(targets),
             target_type,
             env
           ) do
      conn
      |> put_status(:accepted)
      |> render(
        accepted_execution: %{
          execution_id: execution_id,
          group_id: group_id
        }
      )
    end
  end

  defp execution_server_impl,
    do: Application.fetch_env!(:wanda, Wanda.Policy)[:execution_server_impl]
end

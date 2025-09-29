defmodule WandaWeb.V1.ExecutionController do
  use WandaWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias OpenApiSpex.Schema

  alias Wanda.Executions
  alias Wanda.Executions.Target

  alias WandaWeb.Schemas.{
    AcceptedExecutionResponse,
    BadRequest,
    NotFound,
    UnprocessableEntity
  }

  alias WandaWeb.Schemas.V1.Execution.{
    ExecutionResponse,
    ListExecutionsResponse,
    StartExecutionRequest
  }

  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true
  action_fallback WandaWeb.FallbackController

  operation :index,
    summary: "List executions.",
    description:
      "Provides a paginated list of executions performed in the system, supporting monitoring and analysis.",
    tags: ["Checks Engine", "MCP"],
    parameters: [
      group_id: [
        in: :query,
        description: "The unique identifier of the group to filter the executions list.",
        type: %Schema{
          type: :string,
          format: :uuid
        },
        example: "c1a2b3c4-d5e6-7890-abcd-ef1234567890"
      ],
      page: [
        in: :query,
        description: "Specify the page number to retrieve paginated results for executions.",
        type: :integer,
        example: 3
      ],
      items_per_page: [
        in: :query,
        description: "Set the number of items to be returned per page in the paginated results.",
        type: :integer,
        example: 20
      ]
    ],
    responses: [
      ok:
        {"A successful response containing a paginated list of executions.", "application/json",
         ListExecutionsResponse},
      unprocessable_entity: UnprocessableEntity.response()
    ]

  def index(conn, params) do
    executions = Executions.list_executions(params)
    total_count = Executions.count_executions(params)

    render(conn, executions: executions, total_count: total_count)
  end

  operation :show,
    summary: "Get an execution by ID.",
    description: "Provides detailed information about a specific execution identified by its ID.",
    tags: ["Checks Engine", "MCP"],
    parameters: [
      id: [
        in: :path,
        description: "The unique identifier of the execution to retrieve details for.",
        type: %Schema{
          type: :string,
          format: :uuid
        },
        example: "c1a2b3c4-d5e6-7890-abcd-ef1234567890"
      ]
    ],
    responses: [
      ok:
        {"A successful response containing details of the requested execution.",
         "application/json", ExecutionResponse},
      not_found: NotFound.response(),
      unprocessable_entity: UnprocessableEntity.response()
    ]

  def show(conn, %{id: execution_id}) do
    execution = Executions.get_execution!(execution_id)

    render(conn, execution: execution)
  end

  operation :last,
    summary: "Get the last execution of a group.",
    description: "Provides details about the most recent execution for a specified group.",
    tags: ["Checks Engine", "MCP"],
    parameters: [
      id: [
        in: :path,
        description:
          "The unique identifier of the group for which the last execution is requested.",
        type: %Schema{
          type: :string,
          format: :uuid
        },
        example: "c1a2b3c4-d5e6-7890-abcd-ef1234567890"
      ]
    ],
    responses: [
      ok:
        {"A successful response containing details of the last execution for the specified group.",
         "application/json", ExecutionResponse},
      not_found: NotFound.response(),
      unprocessable_entity: UnprocessableEntity.response()
    ]

  def last(conn, %{id: group_id}) do
    execution = Executions.get_last_execution_by_group_id!(group_id)

    render(conn, :show, execution: execution)
  end

  operation :start,
    summary: "Start a Checks Execution.",
    description:
      "Initiates a new checks execution on the target infrastructure, enabling automated validation.",
    tags: ["Checks Engine"],
    request_body:
      {"The context required to start a new execution, including necessary parameters.",
       "application/json", StartExecutionRequest},
    responses: [
      accepted:
        {"A successful response indicating the execution was accepted and started.",
         "application/json", AcceptedExecutionResponse},
      bad_request: BadRequest.response(),
      unprocessable_entity: UnprocessableEntity.response()
    ]

  def start(
        conn,
        _params
      ) do
    %{
      execution_id: execution_id,
      group_id: group_id,
      targets: targets,
      env: env,
      target_type: target_type
    } = OpenApiSpex.body_params(conn)

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

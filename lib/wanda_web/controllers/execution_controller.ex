defmodule WandaWeb.ExecutionController do
  use WandaWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias OpenApiSpex.Schema

  alias Wanda.Executions
  alias Wanda.Executions.{Server, Target}

  alias WandaWeb.Schemas.{
    AcceptedExecutionResponse,
    ExecutionResponse,
    ListExecutionsResponse,
    StartExecutionRequest
  }

  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true

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
    responses: %{
      200 => {"List executions response", "application/json", ListExecutionsResponse},
      422 => OpenApiSpex.JsonErrorResponse.response()
    }

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
    responses: %{
      200 => {"Execution", "application/json", ExecutionResponse},
      404 => OpenApiSpex.JsonErrorResponse.response()
    }

  operation :start,
    summary: "Start a Checks Execution",
    description: "Trigger a Checks Execution on the target infrastructure",
    request_body: {"Execution Context", "application/json", StartExecutionRequest},
    responses: %{
      202 => {"AcceptedExecution", "application/json", AcceptedExecutionResponse},
      422 => OpenApiSpex.JsonErrorResponse.response()
    }

  def index(conn, params) do
    executions = Executions.list_executions(params)
    total_count = Executions.count_executions(params)

    render(conn, executions: executions, total_count: total_count)
  end

  def show(conn, %{id: execution_id}) do
    execution = Executions.get_execution!(execution_id)

    render(conn, execution: execution)
  end

  def start(
        conn,
        _params
      ) do
    %{
      execution_id: execution_id,
      group_id: group_id,
      targets: targets,
      env: env
    } = Map.get(conn, :body_params)

    case Server.start_execution(execution_id, group_id, Target.from_list(targets), env) do
      :ok ->
        conn
        |> put_status(:accepted)
        |> json(%{
          execution_id: execution_id,
          group_id: group_id
        })

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: reason})
    end
  end
end

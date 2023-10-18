defmodule WandaWeb.V2.ExecutionController do
  use WandaWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Wanda.Executions.Target

  alias WandaWeb.Schemas.{
    AcceptedExecutionResponse,
    BadRequest
  }

  alias WandaWeb.Schemas.V2.StartExecutionRequest

  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true
  action_fallback WandaWeb.FallbackController

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

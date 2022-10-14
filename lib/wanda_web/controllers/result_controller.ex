defmodule WandaWeb.ResultController do
  use WandaWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias OpenApiSpex.Schema

  alias Wanda.Results
  alias WandaWeb.Schemas.{ListResultsResponse, Result}

  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true

  operation :index,
    summary: "List results",
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
      200 => {"List results response", "application/json", ListResultsResponse},
      422 => OpenApiSpex.JsonErrorResponse.response()
    }

  operation :show,
    summary: "Get a result by execution ID",
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
      200 => {"Result", "application/json", Result},
      422 => OpenApiSpex.JsonErrorResponse.response()
    }

  def index(conn, params) do
    results = Results.list_execution_results(params)
    total_count = Results.count_execution_results(params)

    render(conn, results: results, total_count: total_count)
  end

  def show(conn, %{id: execution_id}) do
    result = Results.get_execution_result!(execution_id)

    render(conn, result: result)
  end
end

defmodule WandaWeb.ResultController do
  use WandaWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias OpenApiSpex.Schema

  alias Wanda.Results
  alias WandaWeb.Schemas.ListResultsResponse

  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true

  operation :list_results,
    summary: "List results",
    parameters: [
      group_id: [
        in: :query,
        description: "Filter by group_id",
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

  def list_results(conn, params) do
    results = Results.list_execution_results(params)
    total_count = Results.count_execution_results(params)

    render(conn, results: results, total_count: total_count)
  end
end

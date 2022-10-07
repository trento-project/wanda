defmodule WandaWeb.ExecutionController do
  use WandaWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Wanda.Results
  alias WandaWeb.Schemas.CheckExecutionResponse

  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true

  operation :list_checks_executions,
    summary: "List checks executions",
    parameters: [
      group_id: [
        in: :query,
        description: "Group ID to filter upon",
        type: :string,
        example: "00000000-0000-0000-0000-000000000001"
      ],
      page: [in: :query, description: "Page", type: :integer, example: 3],
      items_per_page: [in: :query, description: "Items per page", type: :integer, example: 20]
    ],
    responses: [
      ok: {"Check executions response", "application/json", CheckExecutionResponse}
    ]

  def list_checks_executions(conn, params) do
    results = Results.list_execution_results(params)
    total_count = Results.count_execution_results(params)
    render(conn, data: results, total_count: total_count)
  end
end

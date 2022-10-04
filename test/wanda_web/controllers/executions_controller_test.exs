defmodule WandaWeb.ExecutionsControllerTest do
  use WandaWeb.ConnCase, async: true
  import OpenApiSpex.TestAssertions
  import Wanda.Factory

  alias Wanda.Results.ExecutionResult
  alias WandaWeb.ApiSpec

  describe "Executions controller" do
    test "listing check executions produces a CheckExecutionResponse", %{conn: conn} do
      [
        %ExecutionResult{},
        %ExecutionResult{},
        %ExecutionResult{},
        %ExecutionResult{},
        %ExecutionResult{}
      ] = insert_list(5, :execution_result)

      json =
        conn
        |> get("/api/checks/executions")
        |> json_response(200)

      api_spec = ApiSpec.spec()
      assert_schema(json, "CheckExecutionResponse", api_spec)
    end
  end
end

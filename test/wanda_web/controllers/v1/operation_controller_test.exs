defmodule WandaWeb.V1.OperationControllerTest do
  use WandaWeb.ConnCase, async: true

  import OpenApiSpex.TestAssertions
  import Wanda.Factory

  alias WandaWeb.Schemas.V1.ApiSpec

  describe "list operations" do
    test "should return a list of operations", %{conn: conn} do
      insert_list(5, :operation, catalog_operation_id: "saptuneapplysolution@v1")

      json =
        conn
        |> get("/api/v1/operations/executions")
        |> json_response(200)

      api_spec = ApiSpec.spec()
      assert_schema(json, "ListOperationsResponse", api_spec)
    end

    test "should return a 422 status code if an invalid paramaters is passed", %{conn: conn} do
      conn = get(conn, "/api/v1/operations/executions?limit=invalid")

      assert 422 == conn.status
    end
  end

  describe "get operation" do
    test "should return an operation", %{conn: conn} do
      %{operation_id: operation_id} =
        insert(:operation, catalog_operation_id: "saptuneapplysolution@v1")

      json =
        conn
        |> get("/api/v1/operations/executions/#{operation_id}")
        |> json_response(200)

      api_spec = ApiSpec.spec()
      assert_schema(json, "OperationResponse", api_spec)
    end

    test "should return an operation with agent reports", %{conn: conn} do
      %{operation_id: operation_id} =
        insert(:operation,
          catalog_operation_id: "saptuneapplysolution@v1",
          agent_reports: build_list(1, :step_report)
        )

      json =
        conn
        |> get("/api/v1/operations/executions/#{operation_id}")
        |> json_response(200)

      api_spec = ApiSpec.spec()
      assert_schema(json, "OperationResponse", api_spec)
    end

    test "should return a 404", %{conn: conn} do
      assert_error_sent(404, fn ->
        get(conn, "/api/v1/operations/executions/#{UUID.uuid4()}")
      end)
    end
  end
end

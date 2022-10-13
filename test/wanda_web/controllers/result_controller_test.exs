defmodule WandaWeb.ResultControllerTest do
  use WandaWeb.ConnCase, async: true

  import OpenApiSpex.TestAssertions
  import Wanda.Factory

  alias WandaWeb.ApiSpec

  describe "list results" do
    test "should return a list of results", %{conn: conn} do
      insert_list(5, :execution_result)

      json =
        conn
        |> get("/api/checks/results")
        |> json_response(200)

      api_spec = ApiSpec.spec()
      assert_schema(json, "ListResultsResponse", api_spec)
    end

    test "should return a 422 status code if an invalid paramaters is passed", %{conn: conn} do
      conn = get(conn, "/api/checks/results?limit=invalid")

      assert 422 == conn.status
    end
  end

  describe "get result" do
    test "should return a result", %{conn: conn} do
      %{execution_id: execution_id} = insert(:execution_result)

      json =
        conn
        |> get("/api/checks/results/#{execution_id}")
        |> json_response(200)

      api_spec = ApiSpec.spec()
      assert_schema(json, "ResultResponse", api_spec)
    end

    test "should return a 404", %{conn: conn} do
      assert_error_sent 404, fn ->
        get(conn, "/api/checks/results/#{UUID.uuid4()}")
      end
    end
  end
end

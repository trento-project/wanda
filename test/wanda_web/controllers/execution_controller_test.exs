defmodule WandaWeb.ExecutionControllerTest do
  use WandaWeb.ConnCase, async: true

  import OpenApiSpex.TestAssertions
  import Wanda.Factory

  alias WandaWeb.ApiSpec

  alias Wanda.Executions.{Server, Target}

  describe "list executions" do
    test "should return a list of executions", %{conn: conn} do
      insert_list(5, :execution)

      json =
        conn
        |> get("/api/checks/executions")
        |> json_response(200)

      api_spec = ApiSpec.spec()
      assert_schema(json, "ListExecutionsResponse", api_spec)
    end

    test "should return a 422 status code if an invalid paramaters is passed", %{conn: conn} do
      conn = get(conn, "/api/checks/executions?limit=invalid")

      assert 422 == conn.status
    end
  end

  describe "get execution" do
    test "should return a running execution", %{conn: conn} do
      %{execution_id: execution_id} = insert(:execution)

      json =
        conn
        |> get("/api/checks/executions/#{execution_id}")
        |> json_response(200)

      api_spec = ApiSpec.spec()
      assert_schema(json, "ExecutionResponse", api_spec)
    end

    test "should return a completed execution", %{conn: conn} do
      %{execution_id: execution_id} =
        :execution
        |> build()
        |> with_completed_status()
        |> insert()

      json =
        conn
        |> get("/api/checks/executions/#{execution_id}")
        |> json_response(200)

      api_spec = ApiSpec.spec()
      assert_schema(json, "ExecutionResponse", api_spec)
    end

    test "should return a 404", %{conn: conn} do
      assert_error_sent 404, fn ->
        get(conn, "/api/checks/executions/#{UUID.uuid4()}")
      end
    end
  end

  describe "start execution" do
    test "should start an execution", %{conn: conn} do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()

      json =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/api/checks/executions/start", %{
          "execution_id" => execution_id,
          "group_id" => group_id,
          "targets" => [
            %{
              "agent_id" => UUID.uuid4(),
              "checks" => ["expect_check"]
            }
          ],
          "env" => %{
            "provider" => "azure"
          }
        })
        |> json_response(202)

      api_spec = ApiSpec.spec()
      assert_schema(json, "AcceptedExecution", api_spec)
    end

    test "should return an error when attempting to start an already running execution", %{
      conn: conn
    } do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()

      targets = [
        %{
          agent_id: UUID.uuid4(),
          checks: ["expect_check"]
        }
      ]

      env = %{
        "provider" => "azure"
      }

      # ?? start_supervised!
      :ok =
        Server.start_execution(
          execution_id,
          group_id,
          Target.from_list(targets),
          env
        )

      json =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/api/checks/executions/start", %{
          "execution_id" => execution_id,
          "group_id" => group_id,
          "targets" => targets,
          "env" => env
        })
        |> json_response(422)

      assert %{"error" => "already_running"} = json
    end

    test "should return an error on validation failure", %{conn: conn} do
      json =
        conn
        |> put_req_header("content-type", "application/json")
        |> post(
          "/api/checks/executions/start",
          %{
            "group_id" => UUID.uuid4(),
            "targets" => [
              %{
                "agent_id" => UUID.uuid4(),
                "checks" => ["expect_check"]
              }
            ],
            "env" => %{
              "provider" => "azure"
            }
          }
        )
        |> json_response(422)

      assert %{
               "errors" => [
                 %{
                   "detail" => "Missing field: execution_id",
                   "source" => %{"pointer" => "/execution_id"},
                   "title" => "Invalid value"
                 }
               ]
             } = json
    end
  end
end

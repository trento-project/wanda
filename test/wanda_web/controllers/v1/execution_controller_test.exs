defmodule WandaWeb.V1.ExecutionControllerTest do
  use WandaWeb.ConnCase, async: true

  import Mox
  import OpenApiSpex.TestAssertions
  import Wanda.Factory

  alias WandaWeb.Schemas.V1.ApiSpec

  alias Wanda.Executions.Target

  setup :verify_on_exit!

  describe "list executions" do
    test "should return a list of executions", %{conn: conn} do
      insert_list(5, :execution)

      json =
        conn
        |> get("/api/v1/checks/executions")
        |> json_response(200)

      api_spec = ApiSpec.spec()
      assert_schema(json, "ListExecutionsResponseV1", api_spec)
    end

    test "should return a 422 status code if an invalid parameters is passed", %{conn: conn} do
      conn = get(conn, "/api/v1/checks/executions?limit=invalid")

      assert 422 == conn.status
    end
  end

  describe "get execution" do
    test "should return a running execution", %{conn: conn} do
      %{execution_id: execution_id} = insert(:execution)

      json =
        conn
        |> get("/api/v1/checks/executions/#{execution_id}")
        |> json_response(200)

      api_spec = ApiSpec.spec()
      assert_schema(json, "ExecutionResponseV1", api_spec)
    end

    test "should return a completed execution", %{conn: conn} do
      targets = build_pair(:execution_target)
      check_results = build(:check_results_from_targets, targets: targets)
      result = build(:result, check_results: check_results, result: :passing)

      %{execution_id: execution_id} =
        insert(:execution, status: :completed, completed_at: DateTime.utc_now(), result: result)

      json =
        conn
        |> get("/api/v1/checks/executions/#{execution_id}")
        |> json_response(200)

      api_spec = ApiSpec.spec()
      assert_schema(json, "ExecutionResponseV1", api_spec)
    end

    test "should return a completed execution with errors", %{conn: conn} do
      checks = ["check_id"]
      [target_1, target_2, target_3] = targets = build_list(3, :execution_target, checks: checks)

      expectation_name = "expectation_with_error"

      expectation_evaluations =
        build_list(1, :expectation_evaluation_error, name: expectation_name)

      agent_check_results = [
        build(:agent_check_result,
          agent_id: target_1.agent_id,
          expectation_evaluations: expectation_evaluations
        ),
        build(:agent_check_error,
          agent_id: target_2.agent_id
        ),
        build(:agent_check_error,
          agent_id: target_3.agent_id,
          facts: nil,
          message: "timeout",
          type: :timeout
        )
      ]

      expectation_results =
        build_list(1, :expectation_result, name: expectation_name, result: false)

      check_results =
        build_list(1, :check_result,
          expectation_results: expectation_results,
          agents_check_results: agent_check_results
        )

      result =
        build(:result,
          check_results: check_results,
          result: :critical,
          timeout: [target_3.agent_id]
        )

      %{execution_id: execution_id} =
        insert(:execution,
          status: :completed,
          completed_at: DateTime.utc_now(),
          targets: targets,
          result: result
        )

      json =
        conn
        |> get("/api/v1/checks/executions/#{execution_id}")
        |> json_response(200)

      api_spec = ApiSpec.spec()
      assert_schema(json, "ExecutionResponseV1", api_spec)
    end

    test "should accept all different types of fact values", %{conn: conn} do
      values = [
        Faker.String.base64(),
        Enum.random(-100..100),
        Enum.random([false, true]),
        %{Faker.String.base64() => Faker.String.base64()},
        [
          Faker.String.base64(),
          Enum.random(-100..100),
          %{Faker.String.base64() => Faker.String.base64()}
        ]
      ]

      for value <- values do
        facts = build_list(1, :fact, value: value)
        agents_check_results = build_list(5, :agent_check_result, facts: facts)
        check_results = build_list(1, :check_result, agents_check_results: agents_check_results)
        result = build(:result, check_results: check_results, result: :passing)

        %{execution_id: execution_id} =
          insert(:execution, status: :completed, completed_at: DateTime.utc_now(), result: result)

        json =
          conn
          |> get("/api/v1/checks/executions/#{execution_id}")
          |> json_response(200)

        api_spec = ApiSpec.spec()
        assert_schema(json, "ExecutionResponseV1", api_spec)
      end
    end

    test "should return a 404", %{conn: conn} do
      assert_error_sent(404, fn ->
        get(conn, "/api/v1/checks/executions/#{UUID.uuid4()}")
      end)
    end
  end

  describe "get last execution by group id" do
    test "should return the last execution", %{conn: conn} do
      %{group_id: group_id} = 10 |> insert_list(:execution) |> List.last()

      json =
        conn
        |> get("/api/v1/checks/groups/#{group_id}/executions/last")
        |> json_response(200)

      api_spec = ApiSpec.spec()
      assert_schema(json, "ExecutionResponseV1", api_spec)
    end

    test "should return a 404", %{conn: conn} do
      assert_error_sent(404, fn ->
        get(conn, "/api/v1/checks/groups/#{UUID.uuid4()}/executions/last")
      end)
    end
  end

  describe "start execution" do
    test "should start an execution", %{conn: conn} do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      target_type = Faker.Person.first_name()

      targets = [
        %{
          "agent_id" => agent_id = UUID.uuid4(),
          "checks" => checks = ["expect_check"]
        }
      ]

      env = build(:env)

      expect(Wanda.Executions.ServerMock, :start_execution, fn ^execution_id,
                                                               ^group_id,
                                                               [
                                                                 %Target{
                                                                   agent_id: ^agent_id,
                                                                   checks: ^checks
                                                                 }
                                                               ],
                                                               ^target_type,
                                                               ^env ->
        :ok
      end)

      json =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/api/v1/checks/executions/start", %{
          "execution_id" => execution_id,
          "group_id" => group_id,
          "targets" => targets,
          "target_type" => target_type,
          "env" => env
        })
        |> json_response(202)

      api_spec = ApiSpec.spec()
      assert_schema(json, "AcceptedExecutionResponseV1", api_spec)
    end

    test "should return an error when the start execution operation fails", %{
      conn: conn
    } do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      target_type = Faker.Person.first_name()

      targets = [
        %{
          agent_id: agent_id = UUID.uuid4(),
          checks: checks = ["expect_check"]
        }
      ]

      env = build(:env)

      expect(Wanda.Executions.ServerMock, :start_execution, fn ^execution_id,
                                                               ^group_id,
                                                               [
                                                                 %Target{
                                                                   agent_id: ^agent_id,
                                                                   checks: ^checks
                                                                 }
                                                               ],
                                                               ^target_type,
                                                               ^env ->
        {:error, :already_running}
      end)

      json =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/api/v1/checks/executions/start", %{
          "execution_id" => execution_id,
          "group_id" => group_id,
          "targets" => targets,
          "target_type" => target_type,
          "env" => env
        })
        |> json_response(422)

      assert %{
               "errors" => [
                 %{"detail" => "Execution already running.", "title" => "Unprocessable Entity"}
               ]
             } = json
    end

    test "should return an error if no checks were selected", %{conn: conn} do
      expect(Wanda.Executions.ServerMock, :start_execution, fn _, _, _, _, _ ->
        {:error, :no_checks_selected}
      end)

      json =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/api/v1/checks/executions/start", %{
          "execution_id" => UUID.uuid4(),
          "group_id" => UUID.uuid4(),
          "targets" => [
            %{
              agent_id: UUID.uuid4(),
              checks: []
            }
          ],
          "target_type" => Faker.Person.first_name(),
          "env" => build(:env)
        })
        |> json_response(422)

      assert %{
               "errors" => [
                 %{
                   "detail" => "No checks were selected.",
                   "title" => "Unprocessable Entity"
                 }
               ]
             } = json
    end
  end
end

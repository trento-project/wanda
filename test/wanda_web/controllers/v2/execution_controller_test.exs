defmodule WandaWeb.V2.ExecutionControllerTest do
  use WandaWeb.ConnCase, async: true

  import Mox
  import OpenApiSpex.TestAssertions
  import Wanda.Factory

  alias WandaWeb.Schemas.V2.ApiSpec

  alias Wanda.Executions.Target

  setup :verify_on_exit!

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
        |> post("/api/v2/checks/executions/start", %{
          "execution_id" => execution_id,
          "group_id" => group_id,
          "targets" => targets,
          "target_type" => target_type,
          "env" => env
        })
        |> json_response(202)

      api_spec = ApiSpec.spec()
      assert_schema(json, "AcceptedExecutionResponse", api_spec)
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
        |> post("/api/v2/checks/executions/start", %{
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
        |> post("/api/v2/checks/executions/start", %{
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

defmodule Wanda.PolicyTest do
  use ExUnit.Case

  import Mox
  import Wanda.Factory

  alias Wanda.Operations.Catalog.TestRegistry

  alias Trento.Checks.V1.{
    ExecutionRequested,
    FactsGathered
  }

  alias Trento.Operations.V1.{
    OperationRequested,
    OperationTarget,
    OperatorDiff,
    OperatorExecutionCompleted,
    OperatorResponse
  }

  alias Wanda.Executions.{Fact, Target}

  setup :verify_on_exit!

  setup do
    Application.put_env(:wanda, :operations_registry, TestRegistry.test_registry())
    on_exit(fn -> Application.delete_env(:wanda, :operations_registry) end)

    {:ok, []}
  end

  test "should handle a ExecutionRequested event" do
    execution_id = UUID.uuid4()
    group_id = UUID.uuid4()
    agent_id = UUID.uuid4()
    target_type = Faker.Person.first_name()

    expect(Wanda.Executions.ServerMock, :start_execution, fn ^execution_id,
                                                             ^group_id,
                                                             [
                                                               %Target{
                                                                 agent_id: ^agent_id,
                                                                 checks: ["check_id"]
                                                               }
                                                             ],
                                                             ^target_type,
                                                             %{
                                                               "key" => "value",
                                                               "other_key" => "other_value"
                                                             } ->
      :ok
    end)

    assert :ok =
             Wanda.Policy.handle_event(%ExecutionRequested{
               execution_id: execution_id,
               group_id: group_id,
               targets: [%{agent_id: agent_id, checks: ["check_id"]}],
               target_type: target_type,
               env: %{
                 "key" => %{kind: {:string_value, "value"}},
                 "other_key" => %{kind: {:string_value, "other_value"}}
               }
             })
  end

  test "should handle a FactsGathered event" do
    execution_id = UUID.uuid4()
    group_id = UUID.uuid4()
    agent_id = UUID.uuid4()

    expect(Wanda.Executions.ServerMock, :receive_facts, fn ^execution_id,
                                                           ^group_id,
                                                           ^agent_id,
                                                           [
                                                             %Fact{
                                                               check_id: "check_id",
                                                               name: "name",
                                                               value: "value"
                                                             }
                                                           ] ->
      :ok
    end)

    assert :ok =
             Wanda.Policy.handle_event(%FactsGathered{
               execution_id: execution_id,
               group_id: group_id,
               agent_id: agent_id,
               facts_gathered: [
                 %{
                   check_id: "check_id",
                   name: "name",
                   fact_value: {:value, %{kind: {:string_value, "value"}}}
                 }
               ]
             })
  end

  describe "OperationRequested" do
    test "should handle a OperationRequested event when operation is not found" do
      operation_id = UUID.uuid4()
      group_id = UUID.uuid4()
      operation_type = "unknown@v1"

      assert {:error, :operation_not_found} =
               Wanda.Policy.handle_event(%OperationRequested{
                 operation_id: operation_id,
                 group_id: group_id,
                 operation_type: operation_type,
                 targets: [
                   %OperationTarget{
                     agent_id: UUID.uuid4(),
                     arguments: %{}
                   },
                   %OperationTarget{
                     agent_id: UUID.uuid4(),
                     arguments: %{}
                   }
                 ]
               })
    end

    test "should handle a OperationRequested event when operation fails" do
      operation_id = UUID.uuid4()
      group_id = UUID.uuid4()
      operation_type = "testoperation@v1"
      operation = Map.get(TestRegistry.test_registry(), operation_type)

      [%{agent_id: agent_id_1}, %{agent_id: agent_id_2}] =
        targets =
        build_list(2, :operation_target, arguments: %{})

      expect(Wanda.Operations.ServerMock, :start_operation, fn ^operation_id,
                                                               ^group_id,
                                                               ^operation,
                                                               ^targets ->
        {:error, :some_error}
      end)

      assert {:error, :some_error} =
               Wanda.Policy.handle_event(%OperationRequested{
                 operation_id: operation_id,
                 group_id: group_id,
                 operation_type: operation_type,
                 targets: [
                   %OperationTarget{
                     agent_id: agent_id_1,
                     arguments: %{}
                   },
                   %OperationTarget{
                     agent_id: agent_id_2,
                     arguments: %{}
                   }
                 ]
               })
    end

    test "should handle a OperationRequested event" do
      operation_id = UUID.uuid4()
      group_id = UUID.uuid4()
      operation_type = "testoperation@v1"
      operation = Map.get(TestRegistry.test_registry(), operation_type)

      [%{agent_id: agent_id_1}, %{agent_id: agent_id_2}] =
        targets =
        build_list(2, :operation_target,
          arguments: %{
            "string" => "some_string",
            "number" => 10,
            "boolean" => true
          }
        )

      expect(Wanda.Operations.ServerMock, :start_operation, fn ^operation_id,
                                                               ^group_id,
                                                               ^operation,
                                                               ^targets ->
        :ok
      end)

      assert :ok =
               Wanda.Policy.handle_event(%OperationRequested{
                 operation_id: operation_id,
                 group_id: group_id,
                 operation_type: operation_type,
                 targets: [
                   %OperationTarget{
                     agent_id: agent_id_1,
                     arguments: %{
                       "string" => %{kind: {:string_value, "some_string"}},
                       "number" => %{kind: {:number_value, 10}},
                       "boolean" => %{kind: {:bool_value, true}}
                     }
                   },
                   %OperationTarget{
                     agent_id: agent_id_2,
                     arguments: %{
                       "string" => %{kind: {:string_value, "some_string"}},
                       "number" => %{kind: {:number_value, 10}},
                       "boolean" => %{kind: {:bool_value, true}}
                     }
                   }
                 ]
               })
    end
  end

  test "should handle a OperatorExecutionCompleted event" do
    operation_id = UUID.uuid4()
    group_id = UUID.uuid4()
    step_number = Enum.random(1..5)
    agent_id = UUID.uuid4()

    result = %Wanda.Operations.OperatorResult{
      phase: :commit,
      diff: %{before: "before", after: "after"}
    }

    expect(Wanda.Operations.ServerMock, :receive_operation_reports, fn ^operation_id,
                                                                       ^group_id,
                                                                       ^step_number,
                                                                       ^agent_id,
                                                                       ^result ->
      :ok
    end)

    assert :ok =
             Wanda.Policy.handle_event(%OperatorExecutionCompleted{
               operation_id: operation_id,
               group_id: group_id,
               step_number: step_number,
               agent_id: agent_id,
               result:
                 {:value,
                  %OperatorResponse{
                    phase: :COMMIT,
                    diff: %OperatorDiff{
                      before: %{kind: {:string_value, "before"}},
                      after: %{kind: {:string_value, "after"}}
                    }
                  }}
             })
  end
end

defmodule Wanda.PolicyTest do
  use ExUnit.Case

  import Mox

  alias Trento.Checks.V1.{
    ExecutionRequested,
    FactsGathered
  }

  alias Wanda.Executions.{Fact, Target}

  setup :verify_on_exit!

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
end

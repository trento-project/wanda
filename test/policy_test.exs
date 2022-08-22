defmodule Wanda.PolicyTest do
  use ExUnit.Case

  import Mox

  alias Cloudevents.Format.V_1_0.Event, as: CloudEvent
  alias Wanda.Execution.{Fact, Target}

  setup :verify_on_exit!

  test "should handle a ExecutionRequested event" do
    execution_id = UUID.uuid4()
    group_id = UUID.uuid4()
    agent_id = UUID.uuid4()
    targets = [%{"agent_id" => agent_id, "checks" => ["check_id"]}]

    expect(Wanda.Execution.Mock, :start_execution, fn ^execution_id,
                                                      ^group_id,
                                                      [
                                                        %Target{
                                                          agent_id: ^agent_id,
                                                          checks: ["check_id"]
                                                        }
                                                      ] ->
      :ok
    end)

    assert :ok =
             Wanda.Policy.handle_event(%CloudEvent{
               id: UUID.uuid4(),
               source: "trento.wanda",
               type: "trento.checks.v1.ExecutionRequested",
               data: %{
                 "execution_id" => execution_id,
                 "group_id" => group_id,
                 "targets" => targets
               }
             })
  end

  test "should handle a FactsGathered event" do
    execution_id = UUID.uuid4()
    agent_id = UUID.uuid4()
    facts = [%{"check_id" => "check_id", "name" => "name", "value" => "value"}]

    expect(Wanda.Execution.Mock, :receive_facts, fn ^execution_id,
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
             Wanda.Policy.handle_event(%CloudEvent{
               id: UUID.uuid4(),
               source: "trento.wanda",
               type: "trento.checks.v1.FactsGathered",
               data: %{"execution_id" => execution_id, "agent_id" => agent_id, "facts" => facts}
             })
  end

  test "should return error if an unknown event is handled" do
    assert {:error, :unsupported_event} =
             Wanda.Policy.handle_event(%CloudEvent{
               id: UUID.uuid4(),
               source: "trento.wanda",
               type: Faker.StarWars.quote(),
               data: %{}
             })
  end
end

defmodule Wanda.Messaging.Adapter.AMQP.ProcessorTest do
  use ExUnit.Case

  import Mox

  alias Trento.Checks.V1.ExecutionRequested

  alias Wanda.Executions.Target
  alias Wanda.Messaging.Adapters.AMQP.Processor

  setup :verify_on_exit!

  describe "Processor" do
    test "should handle an ExecutionRequested event" do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      agent_id = UUID.uuid4()
      target_type = Faker.Person.first_name()

      event =
        Trento.Contracts.to_event(%ExecutionRequested{
          execution_id: execution_id,
          group_id: group_id,
          targets: [%{agent_id: agent_id, checks: ["check_id"]}],
          target_type: target_type,
          env: %{
            "key" => %{kind: {:string_value, "value"}},
            "other_key" => %{kind: {:string_value, "other_value"}}
          }
        })

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
               Processor.process(%GenRMQ.Message{
                 payload: event,
                 attributes: [],
                 channel: ""
               })
    end

    test "should error when no compatible event is found" do
      assert {:error, _} =
               Processor.process(%GenRMQ.Message{
                 payload: %{},
                 attributes: [],
                 channel: ""
               })
    end
  end
end

defmodule Wanda.Messaging.Adapters.AMQP.ConsumerTest do
  use ExUnit.Case

  import Mox

  alias Trento.Checks.V1.{
    ExecutionRequested,
    FactsGathered
  }

  alias Wanda.Messaging.Adapters.AMQP.Publisher

  setup [:set_mox_from_context, :verify_on_exit!]

  @moduletag :integration

  describe "handle_message/1" do
    test "should consume ExecutionRequested" do
      pid = self()

      expect(Wanda.Execution.Mock, :start_execution, fn _, _, _, _ ->
        send(pid, :consumed)
        :ok
      end)

      assert :ok =
               %{
                 execution_id: UUID.uuid4(),
                 group_id: UUID.uuid4(),
                 targets: [%{agent_id: UUID.uuid4(), checks: ["check_id"]}],
                 env: %{"key" => "value"}
               }
               |> ExecutionRequested.new!()
               |> Trento.Contracts.to_event()
               |> Publisher.publish_message("executions")

      assert_receive :consumed, 1_000
    end

    test "should consume FactsGathered" do
      pid = self()

      expect(Wanda.Execution.Mock, :receive_facts, fn _, _, _ ->
        send(pid, :consumed)
        :ok
      end)

      assert :ok =
               %{
                 execution_id: UUID.uuid4(),
                 agent_id: UUID.uuid4(),
                 facts_gathered: [
                   %{check_id: "check_id", name: "name", value: {:text_value, "value"}}
                 ]
               }
               |> FactsGathered.new!()
               |> Trento.Contracts.to_event()
               |> Publisher.publish_message("executions")

      assert_receive :consumed, 1_000
    end
  end

  describe "handle_error/1" do
    test "should reject unknown events and move them to the dead letter queue" do
      config = Application.fetch_env!(:wanda, Wanda.Messaging.Adapters.AMQP)[:consumer]
      connection = Keyword.get(config, :connection)
      routing_key = Keyword.get(config, :routing_key)
      deadletter_queue = Keyword.get(config, :queue) <> "_error"

      assert :ok = Publisher.publish_message("bad_payload", routing_key)

      {:ok, conn} = AMQP.Connection.open(connection)
      {:ok, chan} = AMQP.Channel.open(conn)
      {:ok, _consumer_tag} = AMQP.Basic.consume(chan, deadletter_queue)

      assert_receive {:basic_deliver, "bad_payload", _}

      :ok = AMQP.Channel.close(chan)
    end
  end
end

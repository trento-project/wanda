defmodule Wanda.Execution.ServerTest do
  use Wanda.Support.MessagingCase, async: false

  import Mox
  import Wanda.Factory

  alias Wanda.Execution.Server

  setup [:set_mox_from_context, :verify_on_exit!]

  describe "start_link/3" do
    test "should accept an execution_id, a group_id and targets on start" do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()

      assert {:ok, pid} =
               start_supervised(
                 {Server,
                  [
                    execution_id: execution_id,
                    group_id: group_id,
                    targets: build_list(10, :target)
                  ]}
               )

      assert pid == :global.whereis_name({Server, execution_id})
    end
  end

  describe "execution orchestration" do
    test "should start an execution" do
      pid = self()

      expect(Wanda.Messaging.Adapters.Mock, :publish, fn "checks.agents.*",
                                                         "initiate_facts_gathering" ->
        send(pid, :wandalorian)

        :ok
      end)

      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()

      start_supervised!(
        {Server,
         [
           execution_id: execution_id,
           group_id: group_id,
           targets: build_list(10, :target)
         ]}
      )

      assert_receive :wandalorian
    end

    test "should exit when all facts are sent by all agents" do
      pid = self()
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()

      targets = build_list(3, :target, %{checks: ["expect_check"]})

      expect(Wanda.Messaging.Adapters.Mock, :publish, 2, fn
        "checks.execution", _ ->
          send(pid, :executed)

          :ok

        _, _ ->
          :ok
      end)

      {:ok, pid} =
        start_supervised(
          {Server,
           [
             execution_id: execution_id,
             group_id: group_id,
             targets: targets
           ]}
        )

      ref = Process.monitor(pid)

      Enum.each(targets, fn target ->
        Server.receive_facts(execution_id, target.agent_id, [
          %Wanda.Execution.Fact{
            check_id: "expect_check",
            name: "corosync_token_timeout",
            value: 30_000
          }
        ])
      end)

      assert_receive :executed
      assert_receive {:DOWN, ^ref, _, ^pid, :normal}
    end
  end
end

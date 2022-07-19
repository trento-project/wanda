defmodule Wanda.ExecutionTest do
  use Wanda.Support.MessagingCase, async: false

  import Mox
  import Wanda.Factory

  alias Wanda.Execution

  setup [:set_mox_from_context, :verify_on_exit!]

  describe "start_link/3" do
    test "should accept an execution_id, a group_id and targets on start" do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()

      assert {:ok, pid} =
               start_supervised(%{
                 id: Execution,
                 start:
                   {Execution, :start_link, [execution_id, group_id, build_list(10, :target)]}
               })

      assert pid == :global.whereis_name({Execution, execution_id})
    end
  end

  describe "execution orchestration" do
    test "should start an execution" do
      pid = self()

      expect(Wanda.Messaging.Adapters.Mock, :publish, fn _ ->
        send(pid, :wandalorian)

        :ok
      end)

      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()

      start_supervised!(%{
        id: {Execution, execution_id},
        start: {Execution, :start_link, [execution_id, group_id, build_list(10, :target)]}
      })

      assert_receive :wandalorian
    end

    test "should exit when all facts are sent by all agents" do
      pid = self()
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()

      targets = build_list(3, :target, %{checks: ["happy"]})

      expect(Wanda.Messaging.Adapters.Mock, :publish, 2, fn
        "stuff2" ->
          send(pid, :executed)

          :ok

        _ ->
          :ok
      end)

      {:ok, pid} =
        start_supervised(%{
          id: {Execution, execution_id},
          start: {Execution, :start_link, [execution_id, group_id, targets]}
        })

      ref = Process.monitor(pid)

      Enum.each(targets, fn target ->
        Execution.receive_facts(execution_id, target.agent_id, [
          %Wanda.Execution.Fact{
            check_id: "happy",
            name: "corosync_token_timeout",
            value: 30_000
          },
          %Wanda.Execution.Fact{
            check_id: "happy",
            name: "http_port_open",
            value: true
          }
        ])
      end)

      assert_receive :executed
      assert_receive {:DOWN, ^ref, _, ^pid, :normal}
    end
  end
end

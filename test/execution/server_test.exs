defmodule Wanda.Execution.ServerTest do
  use Wanda.Support.MessagingCase, async: false
  use Wanda.DataCase

  import Mox
  import Wanda.Factory

  alias Trento.Checks.V1.FactsGatheringRequested
  alias Wanda.Catalog

  alias Wanda.Execution.{ExecutionResult, Server}

  setup [:set_mox_from_context, :verify_on_exit!]

  describe "start_link/3" do
    test "should accept an execution_id, a group_id, targets and checks on start" do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      targets = build_list(10, :target)

      checks =
        targets
        |> Enum.flat_map(& &1.checks)
        |> Enum.map(&build(:check, id: &1))

      assert {:ok, pid} =
               start_supervised(
                 {Server,
                  [
                    execution_id: execution_id,
                    group_id: group_id,
                    targets: targets,
                    checks: checks
                  ]}
               )

      history_log = Repo.all(ExecutionResult)

      assert pid == :global.whereis_name({Server, execution_id})
      assert Enum.empty?(history_log)
    end
  end

  describe "execution orchestration" do
    test "should start an execution" do
      pid = self()

      expect(Wanda.Messaging.Adapters.Mock, :publish, fn "agents", %FactsGatheringRequested{} ->
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
           targets: build_list(10, :target),
           checks: build_list(10, :check)
         ]}
      )

      history_log = Repo.all(ExecutionResult)

      assert_receive :wandalorian
      assert Enum.empty?(history_log)
    end

    test "should exit when all facts are sent by all agents" do
      pid = self()
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()

      targets = build_list(3, :target, %{checks: ["expect_check"]})

      expect(Wanda.Messaging.Adapters.Mock, :publish, 2, fn
        "results", _ ->
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
             targets: targets,
             checks: [Catalog.get_check("expect_check")]
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

      history_log = Repo.all(ExecutionResult)
      assert 1 == length(history_log)
      assert [%ExecutionResult{execution_id: ^execution_id}] = history_log
    end

    test "should timeout" do
      pid = self()
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()

      targets = build_list(3, :target, %{checks: ["expect_check"]})

      expect(Wanda.Messaging.Adapters.Mock, :publish, 2, fn
        "results", _ ->
          send(pid, :timeout)

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
             targets: targets,
             checks: [Catalog.get_check("expect_check")],
             config: [timeout: 100]
           ]}
        )

      ref = Process.monitor(pid)

      assert_receive :timeout, 200

      assert_receive {:DOWN, ^ref, _, ^pid, :normal}

      history_log = Repo.all(ExecutionResult)
      assert 1 == length(history_log)

      assert [%ExecutionResult{execution_id: ^execution_id, group_id: ^group_id}] = history_log
    end

    test "should go down when the timeout function gets called" do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()

      targets = build_list(3, :target, %{checks: ["expect_check"]})

      {:ok, pid} =
        start_supervised(
          {Server,
           [
             execution_id: execution_id,
             group_id: group_id,
             targets: targets,
             checks: [Catalog.get_check("expect_check")],
             config: [timeout: 99_999]
           ]}
        )

      ref = Process.monitor(pid)

      # TODO: test partial gathering of facts before sending the timeout signal

      Process.send(pid, :timeout, [:noconnect])

      assert_receive {:DOWN, ^ref, _, ^pid, :normal}

      history_log = Repo.all(ExecutionResult)
      assert 1 == length(history_log)

      assert [
               %ExecutionResult{
                 execution_id: ^execution_id,
                 group_id: ^group_id,
                 payload: %{
                   "execution_id" => ^execution_id,
                   "group_id" => ^group_id,
                   "timeout" => timedout_targets
                 }
               }
             ] = history_log

      assert timedout_targets == Enum.map(targets, & &1.agent_id)
    end
  end
end

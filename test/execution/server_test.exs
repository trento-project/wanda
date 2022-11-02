defmodule Wanda.Execution.ServerTest do
  use Wanda.Support.MessagingCase, async: false
  use Wanda.DataCase

  import Mox
  import Wanda.Factory

  alias Trento.Checks.V1.FactsGatheringRequested
  alias Wanda.Catalog

  alias Wanda.Execution.{Server, State}
  alias Wanda.Results.ExecutionResult

  setup [:set_mox_from_context, :verify_on_exit!]

  setup_all do
    [%Catalog.Fact{name: fact_name}] = catalog_facts = build_list(1, :catalog_fact)

    expectations =
      build_list(1, :catalog_expectation,
        type: :expect,
        expression: "#{fact_name}"
      )

    check = build(:check, facts: catalog_facts, values: [], expectations: expectations)

    {:ok, check: check}
  end

  describe "start_link/3" do
    test "should accept an execution_id, a group_id, targets, checks and env on start" do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      targets = build_list(10, :target)

      checks =
        targets
        |> Enum.flat_map(& &1.checks)
        |> Enum.map(&build(:check, id: &1))

      env = build(:env)

      assert {:ok, pid} =
               start_supervised(
                 {Server,
                  [
                    execution_id: execution_id,
                    group_id: group_id,
                    targets: targets,
                    checks: checks,
                    env: env
                  ]}
               )

      assert pid == :global.whereis_name({Server, group_id})
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
      env = build(:env)

      start_supervised!(
        {Server,
         [
           execution_id: execution_id,
           group_id: group_id,
           targets: build_list(10, :target),
           checks: build_list(10, :check),
           env: env
         ]}
      )

      assert_receive :wandalorian

      assert %ExecutionResult{execution_id: ^execution_id, status: :running} =
               Repo.one!(ExecutionResult)
    end

    test "should exit when all facts are sent by all agents", context do
      pid = self()
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      env = build(:env)

      targets = build_list(3, :target, %{checks: [context[:check].id]})

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
             checks: [context[:check]],
             env: env
           ]}
        )

      ref = Process.monitor(pid)

      Enum.each(targets, fn target ->
        Server.receive_facts(
          execution_id,
          group_id,
          target.agent_id,
          build_list(1, :fact, check_id: context[:check].id)
        )
      end)

      assert_receive :executed
      assert_receive {:DOWN, ^ref, _, ^pid, :normal}

      assert %ExecutionResult{execution_id: ^execution_id, status: :completed} =
               Repo.one!(ExecutionResult)
    end

    test "should timeout", context do
      pid = self()
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      env = build(:env)

      targets = build_list(3, :target, %{checks: [context[:check].id]})

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
             checks: [context[:check]],
             env: env,
             config: [timeout: 100]
           ]}
        )

      ref = Process.monitor(pid)

      assert_receive :timeout, 200

      assert_receive {:DOWN, ^ref, _, ^pid, :normal}

      assert %ExecutionResult{
               execution_id: ^execution_id,
               group_id: ^group_id,
               status: :completed
             } = Repo.one!(ExecutionResult)
    end

    test "should go down when the timeout function gets called", context do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      env = build(:env)

      targets = build_list(3, :target, %{checks: [context[:check].id]})

      {:ok, pid} =
        start_supervised(
          {Server,
           [
             execution_id: execution_id,
             group_id: group_id,
             targets: targets,
             checks: [context[:check]],
             env: env,
             config: [timeout: 99_999]
           ]}
        )

      ref = Process.monitor(pid)

      # TODO: test partial gathering of facts before sending the timeout signal

      Process.send(pid, :timeout, [:noconnect])

      assert_receive {:DOWN, ^ref, _, ^pid, :normal}

      assert %ExecutionResult{
               execution_id: ^execution_id,
               group_id: ^group_id,
               status: :completed,
               payload: %{
                 "timeout" => timedout_targets
               }
             } = Repo.one!(ExecutionResult)

      assert timedout_targets == Enum.map(targets, & &1.agent_id)
    end

    @tag capture_log: true
    test "should discard execution ids that does not match for current group", context do
      state = %State{
        execution_id: UUID.uuid4(),
        group_id: UUID.uuid4(),
        targets: build_list(2, :target, %{checks: [context[:check].id]})
      }

      assert {:noreply, ^state} =
               Server.handle_cast(
                 {:receive_facts, UUID.uuid4(), UUID.uuid4(), []},
                 state
               )
    end
  end
end

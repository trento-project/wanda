# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: Apache-2.0

defmodule Wanda.Executions.ServerTest do
  use Wanda.Support.MessagingCase, async: false
  use Wanda.DataCase

  import Mox
  import Wanda.Factory

  alias Trento.Checks.V1.{
    ExecutionCompleted,
    ExecutionStarted,
    FactsGatheringRequested
  }

  alias Wanda.Catalog

  alias Wanda.Executions.{Execution, Server, State}

  alias Wanda.Executions.Messaging.Publisher

  setup [:set_mox_from_context, :verify_on_exit!]

  setup_all do
    [%Catalog.Fact{name: fact_name}] = catalog_facts = build_list(1, :catalog_fact)

    expectations =
      build_list(1, :catalog_expectation,
        type: :expect,
        expression: "#{fact_name}"
      )

    spec = build(:check, facts: catalog_facts, values: [], expectations: expectations)
    selected_check = build(:selected_check, spec: spec)

    {:ok, check: selected_check}
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

      stop_supervised(Server)
    end
  end

  describe "execution orchestration" do
    test "should start an execution" do
      pid = self()

      expect(Wanda.Messaging.Adapters.Mock, :publish, 2, fn
        Publisher, "agents", %FactsGatheringRequested{}, _ ->
          send(pid, :wandalorian)

        Publisher, "results", %ExecutionStarted{}, _ ->
          send(pid, :toniolorian)
          :ok
      end)

      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      env = build(:env)

      checks = build_list(10, :selected_check)
      check_ids = Enum.map(checks, & &1.id)

      start_supervised!(
        {Server,
         [
           execution_id: execution_id,
           group_id: group_id,
           targets: build_list(10, :target, checks: check_ids),
           checks: checks,
           env: env
         ]}
      )

      assert_receive :wandalorian
      assert_receive :toniolorian

      assert %Execution{execution_id: ^execution_id, status: :running} = Repo.one!(Execution)

      stop_supervised(Server)
    end

    test "should not start an execution if an execution for that specific group_id is running" do
      group_id = UUID.uuid4()
      targets = build_list(2, :target, checks: ["expect_check"])

      expect(Wanda.Messaging.Adapters.Mock, :publish, 0, fn _, _, _, _ -> :ok end)

      start_supervised!(
        {Server,
         [
           execution_id: UUID.uuid4(),
           group_id: group_id,
           targets: targets,
           checks: build_list(10, :selected_check),
           env: %{}
         ]}
      )

      assert {:error, :already_running} =
               Server.start_execution(UUID.uuid4(), group_id, targets, "cluster", %{})

      stop_supervised(Server)
    end

    test "should exit when all facts are sent by all agents", context do
      pid = self()
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      env = build(:env)

      targets = build_list(3, :target, %{checks: [context[:check].id]})

      expect(Wanda.Messaging.Adapters.Mock, :publish, 3, fn
        Publisher, "results", _, _ ->
          send(pid, :executed)

          :ok

        _, _, _, _ ->
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

      assert %Execution{execution_id: ^execution_id, status: :completed} = Repo.one!(Execution)
    end

    test "should timeout", context do
      pid = self()
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      env = build(:env)

      targets = build_list(3, :target, %{checks: [context[:check].id]})

      expect(Wanda.Messaging.Adapters.Mock, :publish, 3, fn
        Publisher, "results", %ExecutionCompleted{}, _ ->
          send(pid, :timeout)

          :ok

        _, _, _, _ ->
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

      assert %Execution{
               execution_id: ^execution_id,
               group_id: ^group_id,
               status: :completed
             } = Repo.one!(Execution)
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

      Process.send(pid, :timeout, [:noconnect])

      assert_receive {:DOWN, ^ref, _, ^pid, :normal}

      assert %Execution{
               execution_id: ^execution_id,
               group_id: ^group_id,
               status: :completed,
               result: %{
                 "timeout" => timedout_targets
               }
             } = Repo.one!(Execution)

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

  describe "execution" do
    test "should skip execution if no checks are selected" do
      targets = build_list(2, :target, checks: [])

      assert {:error, :no_checks_selected} =
               Server.start_execution(
                 UUID.uuid4(),
                 UUID.uuid4(),
                 targets,
                 Faker.Person.first_name(),
                 %{}
               )
    end

    test "should execute existing checks if non-existent checks are selected" do
      group_id = UUID.uuid4()

      [%{agent_id: agent_1}, %{agent_id: agent_2}] =
        targets = [
          build(:target, checks: ["expect_check", "non_existing"]),
          build(:target, checks: ["expect_same_check", "non_existing"])
        ]

      assert :ok =
               Server.start_execution(
                 UUID.uuid4(),
                 group_id,
                 targets,
                 Faker.Person.first_name(),
                 %{}
               )

      pid = :global.whereis_name({Server, group_id})
      %{targets: actual_targets} = :sys.get_state(pid)

      expected_targets = [
        build(:target, agent_id: agent_1, checks: ["expect_check"]),
        build(:target, agent_id: agent_2, checks: ["expect_same_check"])
      ]

      assert actual_targets == expected_targets
    end
  end

  describe "exclusion predicates" do
    test "check without exclude field keeps all targets" do
      group_id = UUID.uuid4()

      targets = [
        build(:target,
          checks: ["expect_check"],
          attributes: %{"any_attribute" => "excluding_value"}
        ),
        build(:target,
          checks: ["expect_check"],
          attributes: %{"any_attribute" => "including_value"}
        )
      ]

      assert :ok =
               Server.start_execution(UUID.uuid4(), group_id, targets, "cluster", %{})

      pid = :global.whereis_name({Server, group_id})
      %{targets: active_targets, excluded_checks: excluded} = :sys.get_state(pid)

      assert length(active_targets) == 2
      assert excluded == []

      stop_supervised(Server)
    end

    test "check with exclude returning true removes target from gathering" do
      pid = self()
      group_id = UUID.uuid4()
      execution_id = UUID.uuid4()

      # exclude_check has `exclude: host.any_attribute == "excluding_value"`
      aws_agent = UUID.uuid4()
      azure_agent = UUID.uuid4()

      targets = [
        build(:target,
          agent_id: aws_agent,
          checks: ["exclude_check"],
          attributes: %{"any_attribute" => "excluding_value"}
        ),
        build(:target,
          agent_id: azure_agent,
          checks: ["exclude_check"],
          attributes: %{"any_attribute" => "including_value"}
        )
      ]

      expect(Wanda.Messaging.Adapters.Mock, :publish, 2, fn
        Publisher, "agents", %FactsGatheringRequested{targets: gathering_targets}, _ ->
          send(pid, {:gathering_targets, gathering_targets})
          :ok

        _, _, _, _ ->
          :ok
      end)

      assert :ok = Server.start_execution(execution_id, group_id, targets, "cluster", %{})

      assert_receive {:gathering_targets, gathering_targets}

      # Only azure agent should receive gathering request
      assert [%{agent_id: ^azure_agent}] = gathering_targets

      stop_supervised(Server)
    end

    test "excluded pairs are recorded with excluded status" do
      group_id = UUID.uuid4()

      aws_agent = UUID.uuid4()
      azure_agent = UUID.uuid4()

      targets = [
        build(:target,
          agent_id: aws_agent,
          checks: ["exclude_check"],
          attributes: %{"any_attribute" => "excluding_value"}
        ),
        build(:target,
          agent_id: azure_agent,
          checks: ["exclude_check"],
          attributes: %{"any_attribute" => "including_value"}
        )
      ]

      pid = self()

      expect(Wanda.Messaging.Adapters.Mock, :publish, 2, fn
        Publisher, "agents", %FactsGatheringRequested{}, _ ->
          send(pid, :agents_published)
          :ok

        _, _, _, _ ->
          :ok
      end)

      assert :ok = Server.start_execution(UUID.uuid4(), group_id, targets, "cluster", %{})

      # Deterministically wait for handle_continue to finish evaluating
      # exclusions and publish the facts-gathering request (the last action
      # before the GenServer sets its state).
      assert_receive :agents_published, 500

      server_pid = :global.whereis_name({Server, group_id})
      %{excluded_checks: excluded} = :sys.get_state(server_pid)

      assert [
               %Wanda.Executions.ExcludedCheckResult{
                 check_id: "exclude_check",
                 agent_id: ^aws_agent,
                 status: :excluded
               }
             ] = excluded

      stop_supervised(Server)
    end

    test "all targets excluded completes execution immediately with excluded entries" do
      pid = self()
      group_id = UUID.uuid4()
      execution_id = UUID.uuid4()

      targets = [
        build(:target,
          checks: ["exclude_check"],
          attributes: %{"any_attribute" => "excluding_value"}
        ),
        build(:target,
          checks: ["exclude_check"],
          attributes: %{"any_attribute" => "excluding_value"}
        )
      ]

      # Expect execution_started + execution_completed (no agents gathering)
      expect(Wanda.Messaging.Adapters.Mock, :publish, 2, fn
        Publisher, "results", %ExecutionCompleted{}, _ ->
          send(pid, :completed)
          :ok

        _, _, _, _ ->
          :ok
      end)

      assert :ok = Server.start_execution(execution_id, group_id, targets, "cluster", %{})
      assert_receive :completed, 500

      assert %Execution{
               execution_id: ^execution_id,
               status: :completed,
               result: %{
                 "check_results" => [
                   %{
                     "check_id" => "exclude_check",
                     "agents_check_results" => [
                       %{"agent_id" => _, "status" => "excluded"},
                       %{"agent_id" => _, "status" => "excluded"}
                     ]
                   }
                 ]
               }
             } = Repo.one!(Execution)

      stop_supervised(Server)
    end

    test "a check excluded for all hosts still appears in the result when other checks run" do
      pid = self()
      group_id = UUID.uuid4()
      execution_id = UUID.uuid4()

      aws_agent = UUID.uuid4()
      azure_agent = UUID.uuid4()

      # Both targets select two checks. `exclude_check` is excluded for every
      # host (attributes match its `exclude` predicate), while `check_without_values`
      # has no `exclude` field and must still run. This forces the non-empty
      # `active_targets` branch, where the bug used to silently drop the
      # fully-excluded check from the final result.
      targets = [
        build(:target,
          agent_id: aws_agent,
          checks: ["check_without_values", "exclude_check"],
          attributes: %{"any_attribute" => "excluding_value"}
        ),
        build(:target,
          agent_id: azure_agent,
          checks: ["check_without_values", "exclude_check"],
          attributes: %{"any_attribute" => "excluding_value"}
        )
      ]

      expect(Wanda.Messaging.Adapters.Mock, :publish, 3, fn
        Publisher, "agents", %FactsGatheringRequested{}, _ ->
          :ok

        Publisher, "results", %ExecutionStarted{}, _ ->
          :ok

        Publisher, "results", %ExecutionCompleted{}, _ ->
          send(pid, :completed)
          :ok

        _, _, _, _ ->
          :ok
      end)

      assert :ok = Server.start_execution(execution_id, group_id, targets, "cluster", %{})

      Enum.each([aws_agent, azure_agent], fn agent_id ->
        Server.receive_facts(
          execution_id,
          group_id,
          agent_id,
          [build(:fact, check_id: "check_without_values", name: "jedi", value: "skywalker")]
        )
      end)

      assert_receive :completed, 500

      assert %Execution{
               execution_id: ^execution_id,
               status: :completed,
               result: %{"check_results" => check_results}
             } = Repo.one!(Execution)

      results_by_check = Map.new(check_results, &{&1["check_id"], &1})

      # The running check is still present and was actually evaluated.
      assert %{"check_id" => "check_without_values"} =
               Map.get(results_by_check, "check_without_values")

      # The fully-excluded check must NOT be silently dropped: it appears as a
      # passing result whose `agents_check_results` lists every host with
      # excluded status.
      assert %{
               "check_id" => "exclude_check",
               "result" => "passing",
               "agents_check_results" => agents_check_results
             } = Map.get(results_by_check, "exclude_check")

      # Every host of the cluster is reported with excluded status for this
      # check.
      assert Enum.sort(Enum.map(agents_check_results, &{&1["agent_id"], &1["status"]})) ==
               Enum.sort([
                 {aws_agent, "excluded"},
                 {azure_agent, "excluded"}
               ])

      # Only the two selected checks should be in the result.
      assert MapSet.new(Map.keys(results_by_check)) ==
               MapSet.new(["check_without_values", "exclude_check"])
    end

    @tag capture_log: true
    test "exclude predicate returning non-boolean keeps the pair and logs warning" do
      group_id = UUID.uuid4()

      # Build a check with an exclude expression that returns a non-boolean
      [%Catalog.Fact{name: fact_name}] = catalog_facts = build_list(1, :catalog_fact)

      spec =
        build(:check,
          facts: catalog_facts,
          values: [],
          expectations: [
            build(:catalog_expectation, type: :expect, expression: "#{fact_name}")
          ],
          exclude: "42"
        )

      selected_check = build(:selected_check, spec: spec)

      targets = [
        build(:target, checks: [spec.id], attributes: %{"any_attribute" => "excluding_value"})
      ]

      pid = self()

      expect(Wanda.Messaging.Adapters.Mock, :publish, 2, fn
        Publisher, "agents", %FactsGatheringRequested{}, _ ->
          send(pid, :agents_published)
          :ok

        _, _, _, _ ->
          :ok
      end)

      start_supervised!(
        {Server,
         execution_id: UUID.uuid4(),
         group_id: group_id,
         targets: targets,
         checks: [selected_check],
         env: %{}}
      )

      # Deterministically wait for handle_continue to finish evaluating the
      # exclude predicate and publish the facts-gathering request before
      # asserting on the GenServer state.
      assert_receive :agents_published, 500

      server_pid = :global.whereis_name({Server, group_id})
      %{targets: active_targets, excluded_checks: excluded} = :sys.get_state(server_pid)

      # Pair is kept when predicate returns non-boolean
      assert length(active_targets) == 1
      assert excluded == []

      stop_supervised(Server)
    end

    @tag capture_log: true
    test "exclude predicate with syntax error keeps the pair and logs warning" do
      group_id = UUID.uuid4()

      [%Catalog.Fact{name: fact_name}] = catalog_facts = build_list(1, :catalog_fact)

      spec =
        build(:check,
          facts: catalog_facts,
          values: [],
          expectations: [
            build(:catalog_expectation, type: :expect, expression: "#{fact_name}")
          ],
          exclude: "this is not valid rhai !!!"
        )

      selected_check = build(:selected_check, spec: spec)

      targets = [build(:target, checks: [spec.id], attributes: %{})]

      pid = self()

      expect(Wanda.Messaging.Adapters.Mock, :publish, 2, fn
        Publisher, "agents", %FactsGatheringRequested{}, _ ->
          send(pid, :agents_published)
          :ok

        _, _, _, _ ->
          :ok
      end)

      start_supervised!(
        {Server,
         execution_id: UUID.uuid4(),
         group_id: group_id,
         targets: targets,
         checks: [selected_check],
         env: %{}}
      )

      assert_receive :agents_published, 500

      server_pid = :global.whereis_name({Server, group_id})
      %{targets: active_targets, excluded_checks: excluded} = :sys.get_state(server_pid)

      assert length(active_targets) == 1
      assert excluded == []

      stop_supervised(Server)
    end

    @tag capture_log: true
    test "exclude predicate on empty attributes keeps the pair (backwards compatibility)" do
      group_id = UUID.uuid4()

      [%Catalog.Fact{name: fact_name}] = catalog_facts = build_list(1, :catalog_fact)

      spec =
        build(:check,
          facts: catalog_facts,
          values: [],
          expectations: [
            build(:catalog_expectation, type: :expect, expression: "#{fact_name}")
          ],
          exclude: "host[\"provider\"] == \"aws\""
        )

      selected_check = build(:selected_check, spec: spec)

      # empty attributes simulates old web version with no attributes
      targets = [build(:target, checks: [spec.id], attributes: %{})]

      pid = self()

      expect(Wanda.Messaging.Adapters.Mock, :publish, 2, fn
        Publisher, "agents", %FactsGatheringRequested{}, _ ->
          send(pid, :agents_published)
          :ok

        _, _, _, _ ->
          :ok
      end)

      start_supervised!(
        {Server,
         execution_id: UUID.uuid4(),
         group_id: group_id,
         targets: targets,
         checks: [selected_check],
         env: %{}}
      )

      assert_receive :agents_published, 500

      server_pid = :global.whereis_name({Server, group_id})
      %{targets: active_targets} = :sys.get_state(server_pid)

      assert length(active_targets) == 1

      stop_supervised(Server)
    end

    test "regression: execution without exclude fields behaves identically to current behaviour",
         context do
      pid = self()
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      env = build(:env)

      targets = build_list(3, :target, %{checks: [context[:check].id]})

      expect(Wanda.Messaging.Adapters.Mock, :publish, 3, fn
        Publisher, "results", _, _ ->
          send(pid, :executed)
          :ok

        _, _, _, _ ->
          :ok
      end)

      {:ok, server_pid} =
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

      ref = Process.monitor(server_pid)

      Enum.each(targets, fn target ->
        Server.receive_facts(
          execution_id,
          group_id,
          target.agent_id,
          build_list(1, :fact, check_id: context[:check].id)
        )
      end)

      assert_receive :executed
      assert_receive {:DOWN, ^ref, _, ^server_pid, :normal}

      assert %Execution{
               execution_id: ^execution_id,
               status: :completed,
               result: %{"check_results" => _}
             } = Repo.one!(Execution)
    end
  end
end

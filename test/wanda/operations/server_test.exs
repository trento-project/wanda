defmodule Wanda.Operations.ServerTest do
  use Wanda.DataCase

  import Wanda.Factory

  alias Wanda.Operations.{Operation, Server}

  describe "operation execution" do
    test "should not start operation if required arguments on targets are missing" do
      catalog_operation = build(:catalog_operation, required_args: ["arg1", "arg2"])

      test_targets = [
        build_list(2, :operation_target),
        [
          build(:operation_target, arguments: %{"arg1" => "value"}),
          build(:operation_target, arguments: %{"arg2" => "value"})
        ],
        [
          build(:operation_target, arguments: %{"arg1" => "value", "arg2" => "value"}),
          build(:operation_target, arguments: %{"arg2" => "value"})
        ],
        [
          build(:operation_target, arguments: %{"arg1" => "value"}),
          build(:operation_target, arguments: %{"arg1" => "value", "arg2" => "value"})
        ]
      ]

      for targets <- test_targets do
        assert {:error, :arguments_missing} =
                 Server.start_operation(
                   UUID.uuid4(),
                   UUID.uuid4(),
                   catalog_operation,
                   targets,
                   %{}
                 )
      end
    end

    test "should not start operation if it is already running for that group_id" do
      group_id = UUID.uuid4()

      Server.start_operation(
        UUID.uuid4(),
        group_id,
        build(:catalog_operation),
        build_list(2, :operation_target),
        []
      )

      pid = :global.whereis_name({Server, group_id})

      assert {:error, :already_running} =
               Server.start_operation(
                 UUID.uuid4(),
                 group_id,
                 build(:catalog_operation),
                 build_list(2, :operation_target),
                 []
               )

      GenServer.stop(pid)
    end

    test "should stop execution if last step failed" do
      operation_id = UUID.uuid4()
      group_id = UUID.uuid4()
      operation = build(:catalog_operation)

      [%{agent_id: agent_id_1}, %{agent_id: agent_id_2}] =
        targets = build_list(2, :operation_target)

      Server.start_operation(
        operation_id,
        group_id,
        operation,
        targets,
        []
      )

      pid = :global.whereis_name({Server, group_id})
      ref = Process.monitor(pid)

      Server.receive_operation_reports(operation_id, group_id, 0, agent_id_1, :updated)
      Server.receive_operation_reports(operation_id, group_id, 0, agent_id_2, :failed)

      assert_receive {:DOWN, ^ref, _, ^pid, :normal}, 500

      %{result: :failed, status: :completed, agent_reports: agent_reports} =
        Repo.get(Operation, operation_id)

      expected_agent_reports = [
        %{
          "step_number" => 0,
          "agents" => [
            %{"agent_id" => agent_id_1, "result" => "updated"},
            %{"agent_id" => agent_id_2, "result" => "failed"}
          ]
        },
        %{
          "step_number" => 1,
          "agents" => [
            %{"agent_id" => agent_id_1, "result" => "not_executed"},
            %{"agent_id" => agent_id_2, "result" => "not_executed"}
          ]
        }
      ]

      assert expected_agent_reports == agent_reports
    end

    test "should complete execution when all steps are executed in the targets" do
      operation_id = UUID.uuid4()
      group_id = UUID.uuid4()

      operation =
        build(:catalog_operation,
          steps: [
            build(:operation_step, predicate: "*"),
            build(:operation_step, predicate: "")
          ]
        )

      [%{agent_id: agent_id_1}, %{agent_id: agent_id_2}] =
        targets = build_list(2, :operation_target)

      Server.start_operation(
        operation_id,
        group_id,
        operation,
        targets,
        []
      )

      pid = :global.whereis_name({Server, group_id})
      ref = Process.monitor(pid)

      # Getting the state of the GenServer make the test wait until the genserver has changed it
      # internal state. It is just a better way of waiting until the process moved on rather
      # than having a fixed sleep code
      :sys.get_state(pid)

      %{status: :running, agent_reports: initial_agent_reports} =
        Repo.get(Operation, operation_id)

      expected_initial_agent_reports = [
        %{
          "step_number" => 0,
          "agents" => [
            %{"agent_id" => agent_id_1, "result" => "not_executed"},
            %{"agent_id" => agent_id_2, "result" => "not_executed"}
          ]
        },
        %{
          "step_number" => 1,
          "agents" => [
            %{"agent_id" => agent_id_1, "result" => "not_executed"},
            %{"agent_id" => agent_id_2, "result" => "not_executed"}
          ]
        }
      ]

      assert expected_initial_agent_reports == initial_agent_reports

      Server.receive_operation_reports(operation_id, group_id, 0, agent_id_1, :updated)
      Server.receive_operation_reports(operation_id, group_id, 0, agent_id_2, :not_updated)

      :sys.get_state(pid)

      %{status: :running, agent_reports: agent_reports} = Repo.get(Operation, operation_id)

      expected_agent_reports = [
        %{
          "step_number" => 0,
          "agents" => [
            %{"agent_id" => agent_id_1, "result" => "updated"},
            %{"agent_id" => agent_id_2, "result" => "not_updated"}
          ]
        },
        %{
          "step_number" => 1,
          "agents" => [
            %{"agent_id" => agent_id_1, "result" => "not_executed"},
            %{"agent_id" => agent_id_2, "result" => "not_executed"}
          ]
        }
      ]

      assert expected_agent_reports == agent_reports

      Server.receive_operation_reports(operation_id, group_id, 1, agent_id_1, :updated)
      Server.receive_operation_reports(operation_id, group_id, 1, agent_id_2, :updated)

      assert_receive {:DOWN, ^ref, _, ^pid, :normal}, 500

      %{result: :updated, status: :completed, agent_reports: final_agent_reports} =
        Repo.get(Operation, operation_id)

      expected_final_agent_reports = [
        %{
          "step_number" => 0,
          "agents" => [
            %{"agent_id" => agent_id_1, "result" => "updated"},
            %{"agent_id" => agent_id_2, "result" => "not_updated"}
          ]
        },
        %{
          "step_number" => 1,
          "agents" => [
            %{"agent_id" => agent_id_1, "result" => "updated"},
            %{"agent_id" => agent_id_2, "result" => "updated"}
          ]
        }
      ]

      assert expected_final_agent_reports == final_agent_reports
    end

    test "should skip operation in agent if predicate is false" do
      operation_id = UUID.uuid4()
      group_id = UUID.uuid4()

      operation =
        build(:catalog_operation, steps: build_list(1, :operation_step, predicate: "value == 5"))

      [%{agent_id: agent_id_1}, %{agent_id: agent_id_2}] =
        targets = [
          build(:operation_target, arguments: %{"value" => 5}),
          build(:operation_target, arguments: %{"value" => 10})
        ]

      Server.start_operation(
        operation_id,
        group_id,
        operation,
        targets,
        []
      )

      pid = :global.whereis_name({Server, group_id})
      ref = Process.monitor(pid)

      Server.receive_operation_reports(operation_id, group_id, 0, agent_id_1, :updated)

      assert_receive {:DOWN, ^ref, _, ^pid, :normal}, 500

      %{result: :updated, status: :completed, agent_reports: agent_reports} =
        Repo.get(Operation, operation_id)

      expected_agent_reports = [
        %{
          "step_number" => 0,
          "agents" => [
            %{"agent_id" => agent_id_1, "result" => "updated"},
            %{"agent_id" => agent_id_2, "result" => "skipped"}
          ]
        }
      ]

      assert expected_agent_reports == agent_reports
    end

    test "should move to the next step if the predicate is false in all agents" do
      operation_id = UUID.uuid4()
      group_id = UUID.uuid4()

      operation =
        build(:catalog_operation, steps: build_list(1, :operation_step, predicate: "value == 5"))

      [%{agent_id: agent_id_1}, %{agent_id: agent_id_2}] =
        targets = [
          build(:operation_target, arguments: %{"value" => 10}),
          build(:operation_target, arguments: %{"value" => 10})
        ]

      Server.start_operation(
        operation_id,
        group_id,
        operation,
        targets,
        []
      )

      pid = :global.whereis_name({Server, group_id})
      ref = Process.monitor(pid)

      assert_receive {:DOWN, ^ref, _, ^pid, :normal}, 500

      %{result: :updated, status: :completed, agent_reports: agent_reports} =
        Repo.get(Operation, operation_id)

      expected_agent_reports = [
        %{
          "step_number" => 0,
          "agents" => [
            %{"agent_id" => agent_id_1, "result" => "skipped"},
            %{"agent_id" => agent_id_2, "result" => "skipped"}
          ]
        }
      ]

      assert expected_agent_reports == agent_reports
    end

    test "should ignore unrecognized operation and step reports" do
      operation_id = UUID.uuid4()
      group_id = UUID.uuid4()

      operation = build(:catalog_operation)

      [%{agent_id: agent_id_1}, %{agent_id: agent_id_2}] =
        targets = build_list(2, :operation_target)

      Server.start_operation(
        operation_id,
        group_id,
        operation,
        targets,
        []
      )

      pid = :global.whereis_name({Server, group_id})
      :sys.get_state(pid)

      operation_state = Repo.get(Operation, operation_id)

      Server.receive_operation_reports(UUID.uuid4(), group_id, 0, agent_id_1, :updated)
      Server.receive_operation_reports(operation_id, group_id, 1, agent_id_2, :updated)

      :sys.get_state(pid)

      assert operation_state == Repo.get(Operation, operation_id)

      GenServer.stop(pid)
    end
  end
end

defmodule Wanda.Operations.ServerTest do
  use ExUnit.Case

  import Wanda.Factory

  alias Wanda.EvaluationEngine

  alias Wanda.Operations.{AgentReport, Server, State, StepReport}

  setup_all do
    engine = EvaluationEngine.new()

    {:ok, %{engine: engine}}
  end

  describe "start_link/3" do
    test "should accept all required arguments on start" do
      group_id = UUID.uuid4()
      operation = build(:operation)
      targets = build_list(2, :operation_target)

      assert {:ok, pid} =
               start_supervised(
                 {Server,
                  [
                    operation_id: UUID.uuid4(),
                    group_id: group_id,
                    operation: operation,
                    targets: targets,
                    timeout: 5,
                    current_step_index: 0,
                    step_failed: false
                  ]}
               )

      assert pid == :global.whereis_name({Server, group_id})

      stop_supervised(Server)
    end
  end

  describe "receive_operation_reports/5" do
    test "should receive operation reports properly" do
      operation_id = UUID.uuid4()
      group_id = UUID.uuid4()
      operation = build(:operation)
      targets = build_list(2, :operation_target)

      {:ok, _pid} =
        start_supervised(
          {Server,
           [
             operation_id: operation_id,
             group_id: group_id,
             operation: operation,
             targets: targets,
             timeout: 5,
             current_step_index: 0,
             step_failed: false
           ]}
        )

      assert :ok ==
               Server.receive_operation_reports(operation_id, group_id, 1, UUID.uuid4(), :updated)
    end
  end

  describe "start operation" do
    test "should skip operation if required arguments on targets are missing" do
      operation = build(:operation, required_args: ["arg1", "arg2"])

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
                   operation,
                   targets,
                   %{}
                 )
      end
    end

    test "should not start operation if it is already running for that group_id" do
      group_id = UUID.uuid4()

      {:ok, _pid} =
        start_supervised(
          {Server,
           [
             operation_id: UUID.uuid4(),
             group_id: group_id,
             operation: build(:operation),
             targets: build_list(2, :operation_target),
             timeout: 5,
             current_step_index: 0,
             step_failed: false
           ]}
        )

      assert {:error, :already_running} =
               Server.start_operation(
                 UUID.uuid4(),
                 group_id,
                 build(:operation),
                 build_list(2, :operation_target),
                 []
               )
    end

    test "should start operation" do
      group_id = UUID.uuid4()
      operation = build(:operation)

      [%{agent_id: agent_id_1}, %{agent_id: agent_id_2}] =
        targets = build_list(2, :operation_target)

      assert :ok =
               Server.start_operation(
                 UUID.uuid4(),
                 group_id,
                 operation,
                 targets,
                 []
               )

      pid = :global.whereis_name({Server, group_id})
      %{agent_reports: agent_reports} = :sys.get_state(pid)

      expected_agent_reports = [
        %StepReport{
          step_number: 0,
          agents: [
            %AgentReport{agent_id: agent_id_1, result: :not_executed},
            %AgentReport{agent_id: agent_id_2, result: :not_executed}
          ]
        },
        %StepReport{
          step_number: 1,
          agents: [
            %AgentReport{agent_id: agent_id_1, result: :not_executed},
            %AgentReport{agent_id: agent_id_2, result: :not_executed}
          ]
        }
      ]

      assert agent_reports == expected_agent_reports
    end
  end

  describe "execute_step" do
    test "should stop execution if last step failed" do
      state = %State{
        step_failed: true,
        agent_reports: [
          %StepReport{
            step_number: 0,
            agents: [%AgentReport{agent_id: UUID.uuid4(), result: :failed}]
          }
        ]
      }

      assert {:stop, :normal, ^state} =
               Server.handle_continue(
                 :execute_step,
                 state
               )
    end

    test "should finish operation if all steps are completed" do
      state = %State{
        current_step_index: 1,
        agent_reports: [
          %StepReport{
            step_number: 0,
            agents: [%AgentReport{agent_id: UUID.uuid4(), result: :updated}]
          }
        ]
      }

      assert {:stop, :normal, ^state} =
               Server.handle_continue(
                 :execute_step,
                 state
               )
    end

    test "should skip step if none of the agents match the predicate", %{engine: engine} do
      operation =
        build(:operation, steps: build_list(1, :operation_step, predicate: "true == false"))

      pending_agent_id = UUID.uuid4()

      state = %State{
        engine: engine,
        operation: operation,
        current_step_index: 0,
        pending_targets_on_step: [pending_agent_id],
        targets: build_list(1, :operation_target, agent_id: pending_agent_id),
        agent_reports: [
          %StepReport{
            step_number: 0,
            agents: [%AgentReport{agent_id: pending_agent_id, result: :not_executed}]
          }
        ]
      }

      assert {:noreply, new_state, {:continue, :execute_step}} =
               Server.handle_continue(
                 :execute_step,
                 state
               )

      assert %State{
               pending_targets_on_step: [],
               current_step_index: 1,
               agent_reports: [
                 %StepReport{
                   step_number: 0,
                   agents: [%AgentReport{agent_id: ^pending_agent_id, result: :skipped}]
                 }
               ]
             } = new_state
    end

    test "should request operation", %{engine: engine} do
      pending_agent_id = UUID.uuid4()

      state = %State{
        engine: engine,
        current_step_index: 0,
        pending_targets_on_step: [pending_agent_id],
        targets: build_list(1, :operation_target, agent_id: pending_agent_id),
        agent_reports: [
          %StepReport{
            step_number: 0,
            agents: [%AgentReport{agent_id: pending_agent_id, result: :not_executed}]
          }
        ]
      }

      predicates = ["*", "", "true == true"]

      for predicate <- predicates do
        operation =
          build(:operation, steps: build_list(1, :operation_step, predicate: predicate))

        state = %State{state | operation: operation}

        assert {:noreply, ^state} =
                 Server.handle_continue(
                   :execute_step,
                   state
                 )
      end
    end
  end

  describe "receive_reports" do
    test "should continue to next step when last step is completed updating agent result" do
      operation_id = UUID.uuid4()
      group_id = UUID.uuid4()
      pending_agent_id = UUID.uuid4()

      state = %State{
        operation_id: operation_id,
        group_id: group_id,
        current_step_index: 0,
        pending_targets_on_step: [pending_agent_id],
        agent_reports: [
          %StepReport{
            step_number: 0,
            agents: [%AgentReport{agent_id: pending_agent_id, result: :not_executed}]
          }
        ]
      }

      assert {:noreply, new_state, {:continue, :execute_step}} =
               Server.handle_cast(
                 {:receive_reports, operation_id, pending_agent_id, 0, :updated},
                 state
               )

      assert %State{
               operation_id: operation_id,
               group_id: group_id,
               pending_targets_on_step: [],
               current_step_index: 1,
               step_failed: false,
               agent_reports: [
                 %StepReport{
                   step_number: 0,
                   agents: [%AgentReport{agent_id: pending_agent_id, result: :updated}]
                 }
               ]
             } == new_state
    end

    test "should wait on step if some agent is pending to report" do
      operation_id = UUID.uuid4()
      group_id = UUID.uuid4()
      pending_agent_id_1 = UUID.uuid4()
      pending_agent_id_2 = UUID.uuid4()

      state = %State{
        operation_id: operation_id,
        group_id: group_id,
        current_step_index: 0,
        pending_targets_on_step: [pending_agent_id_1, pending_agent_id_2],
        agent_reports: [
          %StepReport{
            step_number: 0,
            agents: [%AgentReport{agent_id: pending_agent_id_1, result: :not_executed}]
          }
        ]
      }

      assert {:noreply, new_state} =
               Server.handle_cast(
                 {:receive_reports, operation_id, pending_agent_id_1, 0, :updated},
                 state
               )

      assert %State{
               operation_id: operation_id,
               group_id: group_id,
               pending_targets_on_step: [pending_agent_id_2],
               current_step_index: 0,
               step_failed: false,
               agent_reports: [
                 %StepReport{
                   step_number: 0,
                   agents: [%AgentReport{agent_id: pending_agent_id_1, result: :updated}]
                 }
               ]
             } == new_state
    end

    test "should set the step as failed of an agent reports with a failed result" do
      operation_id = UUID.uuid4()
      group_id = UUID.uuid4()
      pending_agent_id = UUID.uuid4()

      state = %State{
        operation_id: operation_id,
        group_id: group_id,
        current_step_index: 0,
        pending_targets_on_step: [pending_agent_id],
        agent_reports: [
          %StepReport{
            step_number: 0,
            agents: [%AgentReport{agent_id: pending_agent_id, result: :not_executed}]
          }
        ]
      }

      assert {:noreply, new_state, {:continue, :execute_step}} =
               Server.handle_cast(
                 {:receive_reports, operation_id, pending_agent_id, 0, :failed},
                 state
               )

      assert %State{
               operation_id: operation_id,
               group_id: group_id,
               pending_targets_on_step: [],
               current_step_index: 1,
               step_failed: true,
               agent_reports: [
                 %StepReport{
                   step_number: 0,
                   agents: [%AgentReport{agent_id: pending_agent_id, result: :failed}]
                 }
               ]
             } == new_state
    end

    test "should ignore unexpected step number" do
      operation_id = UUID.uuid4()

      state = %State{
        operation_id: operation_id,
        current_step_index: 0
      }

      assert {:noreply, ^state} =
               Server.handle_cast(
                 {:receive_reports, operation_id, UUID.uuid4(), 1, :update},
                 state
               )
    end

    test "should ignore unexpected operation id" do
      state = %State{
        operation_id: UUID.uuid4(),
        group_id: UUID.uuid4(),
        current_step_index: 0
      }

      assert {:noreply, ^state} =
               Server.handle_cast(
                 {:receive_reports, UUID.uuid4(), UUID.uuid4(), 0, :update},
                 state
               )
    end
  end
end

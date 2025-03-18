defmodule Wanda.OperationsTest do
  use ExUnit.Case
  use Wanda.DataCase

  import Wanda.Factory

  alias Wanda.Operations
  alias Wanda.Operations.{AgentReport, Operation, OperationTarget, StepReport}

  alias Wanda.Operations.Catalog.TestRegistry

  require Wanda.Operations.Enums.Result, as: Result
  require Wanda.Operations.Enums.Status, as: Status

  @existing_catalog_operation_id "testoperation@v1"

  setup do
    Application.put_env(:wanda, :operations_registry, TestRegistry.test_registry())
    on_exit(fn -> Application.delete_env(:wanda, :operations_registry) end)

    {:ok, []}
  end

  describe "create an operation" do
    test "should create a running operation" do
      operation_id = UUID.uuid4()
      group_id = UUID.uuid4()

      [
        %OperationTarget{
          agent_id: agent_id_1,
          arguments: args_1
        },
        %OperationTarget{
          agent_id: agent_id_2,
          arguments: args_2
        }
      ] = targets = build_list(2, :operation_target)

      Operations.create_operation!(
        operation_id,
        group_id,
        @existing_catalog_operation_id,
        targets
      )

      assert %Operation{
               operation_id: ^operation_id,
               group_id: ^group_id,
               result: Result.not_executed(),
               status: Status.running(),
               catalog_operation_id: @existing_catalog_operation_id,
               targets: [
                 %{
                   agent_id: ^agent_id_1,
                   arguments: ^args_1
                 },
                 %{
                   agent_id: ^agent_id_2,
                   arguments: ^args_2
                 }
               ],
               agent_reports: []
             } = Repo.get(Operation, operation_id)
    end

    test "should bang creating operation if catalog operation does not exist" do
      operation_id = UUID.uuid4()
      group_id = UUID.uuid4()
      targets = build_list(2, :operation_target)

      assert_raise Ecto.InvalidChangesetError, fn ->
        Operations.create_operation!(operation_id, group_id, "foo", targets)
      end
    end
  end

  describe "get operation" do
    test "should return an existing operation" do
      %Operation{operation_id: operation_id} =
        operation = insert(:operation, [], returning: true)

      assert operation == Operations.get_operation!(operation_id)
    end
  end

  describe "enrich operation" do
    test "should enrich an existing operation" do
      operation = insert(:operation)

      assert %Operation{catalog_operation: catalog_operation} =
               Operations.enrich_operation!(operation)

      refute catalog_operation == nil
    end

    test "should bang enrichment if catalog operation does not exist" do
      operation = insert(:operation, catalog_operation_id: "bar")

      assert_raise KeyError, fn ->
        Operations.enrich_operation!(operation)
      end
    end
  end

  describe "compute aborted" do
    test "should not change status if the operation is completed" do
      operation = build(:operation, status: Status.completed())

      assert %Operation{status: Status.completed()} =
               Operations.compute_aborted(operation, DateTime.utc_now())
    end

    test "should not change status if the operation is already aborted" do
      operation = build(:operation, status: Status.aborted())

      assert %Operation{status: Status.aborted()} =
               Operations.compute_aborted(operation, DateTime.utc_now())
    end

    test "should not change status if the operation is running but the timeout is not expired" do
      catalog_operation =
        build(:catalog_operation,
          steps: [
            build(:operation_step, timeout: 15_000),
            build(:operation_step, timeout: 5_000),
            build(:operation_step, timeout: 10_000)
          ]
        )

      %{started_at: started_at} =
        operation =
        build(:operation, catalog_operation: catalog_operation, status: Status.running())

      for added_time <- [0, 15, 30] do
        assert %Operation{status: Status.running()} =
                 Operations.compute_aborted(
                   operation,
                   DateTime.add(started_at, added_time)
                 )
      end
    end

    test "should change status to aborted if the operation is running and the timeout expired" do
      catalog_operation =
        build(:catalog_operation,
          steps: [
            build(:operation_step, timeout: 3_000),
            build(:operation_step, timeout: 5_000),
            build(:operation_step, timeout: 7_000)
          ]
        )

      %{started_at: started_at} =
        operation =
        build(:operation, catalog_operation: catalog_operation, status: Status.running())

      assert %Operation{status: Status.aborted()} =
               Operations.compute_aborted(
                 operation,
                 DateTime.add(started_at, 16)
               )
    end
  end

  describe "list operations" do
    test "should list all operations sorted by newest to oldest" do
      operations = insert_list(3, :operation, [], returning: true)

      assert Enum.reverse(operations) == Operations.list_operations()
    end

    test "should list operations grouped by group_id" do
      group_id = UUID.uuid4()
      insert_list(3, :operation, group_id: UUID.uuid4())
      operations = insert_list(3, :operation, [group_id: group_id], returning: true)
      insert_list(3, :operation, group_id: UUID.uuid4())

      assert Enum.reverse(operations) == Operations.list_operations(%{group_id: group_id})
    end

    test "should list operations paginated and with items per page" do
      operations = insert_list(10, :operation, [], returning: true)

      expected_operartions =
        operations
        |> Enum.reverse()
        |> Enum.slice(3, 3)

      assert expected_operartions == Operations.list_operations(%{page: 2, items_per_page: 3})
    end
  end

  describe "update agent reports" do
    test "should update agent reports on a running operation" do
      %Operation{
        operation_id: operation_id,
        group_id: group_id
      } = insert(:operation, status: Status.running())

      %AgentReport{
        agent_id: agent_id_1,
        result: agent_result_1,
        diff: %{
          before: agent_before_1,
          after: agent_after_1
        }
      } = agent_report_1 = build(:agent_report)

      %AgentReport{
        agent_id: agent_id_2,
        result: agent_result_2,
        diff: %{
          before: agent_before_2,
          after: agent_after_2
        }
      } = agent_report_2 = build(:agent_report)

      %AgentReport{
        agent_id: agent_id_3,
        result: agent_result_3,
        error_message: agent_message_3
      } = agent_report_3 = build(:agent_report, diff: nil, error_message: Faker.Lorem.sentence())

      %AgentReport{
        agent_id: agent_id_4,
        result: agent_result_4,
        error_message: agent_message_4
      } = agent_report_4 = build(:agent_report, diff: nil, error_message: Faker.Lorem.sentence())

      [
        %StepReport{step_number: step_number_1},
        %StepReport{step_number: step_number_2}
      ] =
        agent_reports = [
          build(:step_report, agents: [agent_report_1, agent_report_2]),
          build(:step_report, agents: [agent_report_3, agent_report_4])
        ]

      Operations.update_agent_reports!(operation_id, agent_reports)

      result_1 = to_string(agent_result_1)
      result_2 = to_string(agent_result_2)
      result_3 = to_string(agent_result_3)
      result_4 = to_string(agent_result_4)

      assert %Operation{
               operation_id: ^operation_id,
               group_id: ^group_id,
               result: Result.not_executed(),
               status: Status.running(),
               agent_reports: [
                 %{
                   step_number: ^step_number_1,
                   agents: [
                     %{
                       agent_id: ^agent_id_1,
                       result: ^result_1,
                       diff: %{
                         before: ^agent_before_1,
                         after: ^agent_after_1
                       },
                       error_message: nil
                     },
                     %{
                       agent_id: ^agent_id_2,
                       result: ^result_2,
                       diff: %{
                         before: ^agent_before_2,
                         after: ^agent_after_2
                       },
                       error_message: nil
                     }
                   ]
                 },
                 %{
                   step_number: ^step_number_2,
                   agents: [
                     %{
                       agent_id: ^agent_id_3,
                       result: ^result_3,
                       diff: nil,
                       error_message: ^agent_message_3
                     },
                     %{
                       agent_id: ^agent_id_4,
                       result: ^result_4,
                       diff: nil,
                       error_message: ^agent_message_4
                     }
                   ]
                 }
               ],
               completed_at: nil
             } = Repo.get(Operation, operation_id)
    end
  end

  describe "abort an operation" do
    test "should abort a running operation" do
      %Operation{
        operation_id: operation_id,
        group_id: group_id
      } = insert(:operation, status: Status.running())

      Operations.abort_operation!(operation_id)

      assert %Operation{
               operation_id: ^operation_id,
               group_id: ^group_id,
               status: Status.aborted(),
               completed_at: nil
             } = Repo.get(Operation, operation_id)
    end
  end

  describe "complete an operation" do
    test "should complete a running operation" do
      %Operation{
        operation_id: operation_id,
        group_id: group_id
      } = insert(:operation, status: Status.running())

      Operations.complete_operation!(operation_id, Result.updated())

      assert %Operation{
               operation_id: ^operation_id,
               group_id: ^group_id,
               result: Result.updated(),
               status: Status.completed(),
               completed_at: completed_at
             } = Repo.get(Operation, operation_id)

      assert nil !== completed_at
    end
  end
end

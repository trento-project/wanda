defmodule Wanda.ExecutionsTest do
  use ExUnit.Case
  use Wanda.DataCase

  import Wanda.Factory

  alias Wanda.Executions
  alias Wanda.Executions.{Execution, Target}

  describe "create an execution" do
    test "should correctly create a running execution" do
      [
        %Execution{execution_id: execution_1, group_id: group_1},
        %Execution{execution_id: execution_2, group_id: group_2},
        %Execution{execution_id: execution_3, group_id: group_3}
      ] = insert_list(3, :execution)

      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()

      [
        %Target{
          agent_id: agent_id_1,
          checks: checks_1
        },
        %Target{
          agent_id: agent_id_2,
          checks: checks_2
        }
      ] = targets = build_list(2, :target)

      Executions.create_execution!(execution_id, group_id, targets)

      assert [
               %Execution{execution_id: ^execution_1, group_id: ^group_1},
               %Execution{execution_id: ^execution_2, group_id: ^group_2},
               %Execution{execution_id: ^execution_3, group_id: ^group_3},
               %Execution{
                 execution_id: ^execution_id,
                 group_id: ^group_id,
                 status: :running,
                 result: %{},
                 targets: [
                   %{
                     agent_id: ^agent_id_1,
                     checks: ^checks_1
                   },
                   %{
                     agent_id: ^agent_id_2,
                     checks: ^checks_2
                   }
                 ]
               }
             ] =
               Execution
               |> order_by(asc: :started_at)
               |> Repo.all()
    end
  end

  describe "complete an execution" do
    test "should complete a running execution" do
      %Execution{
        execution_id: execution_id,
        group_id: group_id
      } = insert(:execution, status: :running)

      assert %Execution{
               execution_id: ^execution_id,
               group_id: ^group_id,
               status: :completed,
               completed_at: completed_at,
               result: %{
                 result: :passing
               }
             } =
               Executions.complete_execution!(
                 execution_id,
                 build(
                   :result,
                   execution_id: execution_id,
                   group_id: group_id,
                   result: :passing
                 )
               )

      assert nil !== completed_at
    end
  end

  describe "get an execution" do
    test "no filter or pagination applied" do
      [
        %Execution{execution_id: execution_1, group_id: group_1},
        %Execution{execution_id: execution_2, group_id: group_2},
        %Execution{execution_id: execution_3, group_id: group_3}
      ] = insert_list(3, :execution)

      assert [
               %Execution{execution_id: ^execution_3, group_id: ^group_3},
               %Execution{execution_id: ^execution_2, group_id: ^group_2},
               %Execution{execution_id: ^execution_1, group_id: ^group_1}
             ] = Executions.list_executions(%{page: 1})
    end

    test "apply filtering by group id" do
      [
        %Execution{execution_id: execution_1, group_id: group_1},
        %Execution{},
        %Execution{}
      ] = insert_list(3, :execution)

      assert [
               %Execution{execution_id: ^execution_1, group_id: ^group_1}
             ] = Executions.list_executions(%{group_id: group_1, page: 1})
    end

    test "apply pagination" do
      [
        %Execution{execution_id: execution_1, group_id: group_1},
        %Execution{execution_id: execution_2, group_id: group_2},
        %Execution{},
        %Execution{},
        %Execution{}
      ] = insert_list(5, :execution)

      assert [
               %Execution{execution_id: ^execution_2, group_id: ^group_2},
               %Execution{execution_id: ^execution_1, group_id: ^group_1}
             ] = Executions.list_executions(%{page: 2, items_per_page: 3})
    end
  end

  describe "get the last execution of group" do
    test "should return the last execution of a group" do
      group_id = Faker.UUID.v4()

      %Execution{execution_id: last_execution_id} =
        10 |> insert_list(:execution, group_id: group_id) |> List.last()

      insert_list(10, :execution)

      assert %Execution{execution_id: ^last_execution_id} =
               Executions.get_last_execution_by_group_id!(group_id)
    end
  end
end

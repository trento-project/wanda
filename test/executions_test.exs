defmodule Wanda.ExecutionsTest do
  use ExUnit.Case
  use Wanda.DataCase

  import Wanda.Factory

  alias Wanda.Executions
  alias Wanda.Executions.{Execution, Target}

  describe "Creating an Execution" do
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
             ] = Repo.all(Execution)
    end
  end

  describe "Completing an Execution" do
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

  describe "Getting Execution" do
    test "no filter or pagination applied" do
      [
        %Execution{execution_id: execution_1, group_id: group_1},
        %Execution{execution_id: execution_2, group_id: group_2},
        %Execution{execution_id: execution_3, group_id: group_3}
      ] = insert_list(3, :execution)

      assert [
               %Execution{execution_id: ^execution_1, group_id: ^group_1},
               %Execution{execution_id: ^execution_2, group_id: ^group_2},
               %Execution{execution_id: ^execution_3, group_id: ^group_3}
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
        %Execution{},
        %Execution{},
        %Execution{},
        %Execution{execution_id: execution_4, group_id: group_4},
        %Execution{execution_id: execution_5, group_id: group_5}
      ] = insert_list(5, :execution)

      assert [
               %Execution{execution_id: ^execution_4, group_id: ^group_4},
               %Execution{execution_id: ^execution_5, group_id: ^group_5}
             ] = Executions.list_executions(%{page: 2, items_per_page: 3})
    end
  end
end

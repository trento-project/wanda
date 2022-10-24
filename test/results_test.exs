defmodule Wanda.ResultsTest do
  use ExUnit.Case
  use Wanda.DataCase

  import Wanda.Factory

  alias Wanda.Execution.Target

  alias Wanda.Results

  alias Wanda.Results.ExecutionResult

  describe "Creating an Execution" do
    test "should correctly create a running execution" do
      [
        %ExecutionResult{execution_id: execution_1, group_id: group_1},
        %ExecutionResult{execution_id: execution_2, group_id: group_2},
        %ExecutionResult{execution_id: execution_3, group_id: group_3}
      ] = insert_list(3, :execution_result)

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

      Results.create_execution_result!(execution_id, group_id, targets)

      assert [
               %ExecutionResult{execution_id: ^execution_1, group_id: ^group_1},
               %ExecutionResult{execution_id: ^execution_2, group_id: ^group_2},
               %ExecutionResult{execution_id: ^execution_3, group_id: ^group_3},
               %ExecutionResult{
                 execution_id: ^execution_id,
                 group_id: ^group_id,
                 status: :running,
                 payload: %{},
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
             ] = Repo.all(ExecutionResult)
    end

    test "should raise an error when trying to create an already existing execution" do
      [
        %ExecutionResult{execution_id: execution_id, group_id: group_id},
        %ExecutionResult{}
      ] = insert_list(2, :execution_result)

      assert_raise Ecto.ConstraintError, fn ->
        Results.create_execution_result!(execution_id, group_id, build_list(2, :target))
      end

      assert 2 =
               ExecutionResult
               |> Repo.all()
               |> length()
    end
  end

  describe "Completing an Execution" do
    test "should correctly complete a running execution" do
      %ExecutionResult{
        execution_id: execution_id,
        group_id: group_id
      } =
        build(:execution_result)
        |> make_running()
        |> insert()

      assert {:ok,
              %ExecutionResult{
                execution_id: ^execution_id,
                group_id: ^group_id,
                status: :completed,
                payload: %{
                  result: :passing
                }
              }} =
               Results.complete_execution_result!(
                 build(
                   :result,
                   execution_id: execution_id,
                   group_id: group_id,
                   result: :passing
                 )
               )
    end

    test "should return an error when trying to complete an already completed execution" do
      %ExecutionResult{
        execution_id: execution_id,
        group_id: group_id
      } =
        build(:execution_result)
        |> make_completed()
        |> insert()

      assert {:error, :already_completed} =
               Results.complete_execution_result!(
                 build(:result,
                   execution_id: execution_id,
                   group_id: group_id
                 )
               )
    end
  end

  describe "Getting Execution Results" do
    test "no filter or pagination applied" do
      [
        %ExecutionResult{execution_id: execution_1, group_id: group_1},
        %ExecutionResult{execution_id: execution_2, group_id: group_2},
        %ExecutionResult{execution_id: execution_3, group_id: group_3}
      ] = insert_list(3, :execution_result)

      assert [
               %ExecutionResult{execution_id: ^execution_1, group_id: ^group_1},
               %ExecutionResult{execution_id: ^execution_2, group_id: ^group_2},
               %ExecutionResult{execution_id: ^execution_3, group_id: ^group_3}
             ] = Results.list_execution_results(%{page: 1})
    end

    test "apply filtering by group id" do
      [
        %ExecutionResult{execution_id: execution_1, group_id: group_1},
        %ExecutionResult{},
        %ExecutionResult{}
      ] = insert_list(3, :execution_result)

      assert [
               %ExecutionResult{execution_id: ^execution_1, group_id: ^group_1}
             ] = Results.list_execution_results(%{group_id: group_1, page: 1})
    end

    test "apply pagination" do
      [
        %ExecutionResult{},
        %ExecutionResult{},
        %ExecutionResult{},
        %ExecutionResult{execution_id: execution_4, group_id: group_4},
        %ExecutionResult{execution_id: execution_5, group_id: group_5}
      ] = insert_list(5, :execution_result)

      assert [
               %ExecutionResult{execution_id: ^execution_4, group_id: ^group_4},
               %ExecutionResult{execution_id: ^execution_5, group_id: ^group_5}
             ] = Results.list_execution_results(%{page: 2, items_per_page: 3})
    end
  end
end

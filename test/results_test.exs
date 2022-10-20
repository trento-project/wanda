defmodule Wanda.ResultsTest do
  use ExUnit.Case
  use Wanda.DataCase

  import Wanda.Factory

  alias Wanda.Results

  alias Wanda.Results.ExecutionResult

  describe "Creating an Execution" do
    test "should correctly create a running execution in an empty system" do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()

      Results.create_execution_result!(execution_id, group_id, [])

      assert %ExecutionResult{
               execution_id: ^execution_id,
               group_id: ^group_id,
               status: :running,
               payload: %{}
             } = Repo.one!(ExecutionResult)
    end

    test "should correctly create a running execution in a non empty system" do
      [
        %ExecutionResult{execution_id: execution_1, group_id: group_1},
        %ExecutionResult{execution_id: execution_2, group_id: group_2},
        %ExecutionResult{execution_id: execution_3, group_id: group_3}
      ] = insert_list(3, :execution_result)

      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()

      Results.create_execution_result!(execution_id, group_id, [])

      assert [
               %ExecutionResult{execution_id: ^execution_1, group_id: ^group_1},
               %ExecutionResult{execution_id: ^execution_2, group_id: ^group_2},
               %ExecutionResult{execution_id: ^execution_3, group_id: ^group_3},
               %ExecutionResult{
                 execution_id: ^execution_id,
                 group_id: ^group_id,
                 status: :running,
                 payload: %{}
               }
             ] = Repo.all(ExecutionResult)
    end

    test "should raise an error when trying to create an already existing execution" do
      [
        %ExecutionResult{execution_id: execution_id, group_id: group_id},
        %ExecutionResult{}
      ] = insert_list(2, :execution_result)

      assert_raise Ecto.ConstraintError, fn ->
        Results.create_execution_result!(execution_id, group_id, [])
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
        group_id: group_id,
        status: :running,
        payload: %{}
      } = insert(:running_execution_result)

      assert %ExecutionResult{
               execution_id: ^execution_id,
               group_id: ^group_id,
               status: :completed,
               payload: %{
                 result: :passing
               }
             } =
               Results.complete_execution_result!(
                 build(
                   :result,
                   execution_id: execution_id,
                   group_id: group_id,
                   result: :passing
                 )
               )
    end

    test "should pass through an already completed execution" do
      %ExecutionResult{
        execution_id: execution_id,
        group_id: group_id,
        status: :completed,
        payload: %Wanda.Execution.Result{
          check_results: [
            %Wanda.Execution.CheckResult{
              agents_check_results: [_ | _],
              check_id: check_id,
              expectation_results: [_ | _],
              result: specific_check_result
            }
          ],
          result: result,
          timeout: timeout
        },
        completed_at: completed_at,
        updated_at: updated_at
      } = insert(:completed_execution_result)

      result = Atom.to_string(result)
      specific_check_result = Atom.to_string(specific_check_result)

      assert %ExecutionResult{
               execution_id: ^execution_id,
               group_id: ^group_id,
               status: :completed,
               payload: %{
                 "check_results" => [
                   %{
                     "agents_check_results" => [_ | _],
                     "check_id" => ^check_id,
                     "expectation_results" => [_ | _],
                     "result" => ^specific_check_result
                   }
                 ],
                 "execution_id" => ^execution_id,
                 "group_id" => ^group_id,
                 "result" => ^result,
                 "timeout" => ^timeout
               },
               completed_at: ^completed_at,
               updated_at: ^updated_at
             } =
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

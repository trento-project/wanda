defmodule Wanda.ResultsTest do
  use ExUnit.Case
  use Wanda.DataCase

  import Wanda.Factory

  alias Wanda.Results

  alias Wanda.Results.ExecutionResult

  describe "Appending Execution Results to the history log" do
    test "should correctly add an item to an empty log" do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()

      build(
        :result,
        execution_id: execution_id,
        group_id: group_id,
        result: :passing
      )
      |> Results.save_result()

      assert %ExecutionResult{
               execution_id: ^execution_id,
               group_id: ^group_id,
               payload: %{
                 "result" => "passing",
                 "check_results" => [_ | _]
               }
             } = Repo.one!(ExecutionResult)
    end

    test "should correctly add an item to a non empty log" do
      [
        %ExecutionResult{execution_id: execution_1, group_id: group_1},
        %ExecutionResult{execution_id: execution_2, group_id: group_2},
        %ExecutionResult{execution_id: execution_3, group_id: group_3}
      ] = insert_list(3, :execution_result)

      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()

      build(
        :result,
        execution_id: execution_id,
        group_id: group_id,
        result: :passing
      )
      |> Results.save_result()

      assert [
               %ExecutionResult{execution_id: ^execution_1, group_id: ^group_1},
               %ExecutionResult{execution_id: ^execution_2, group_id: ^group_2},
               %ExecutionResult{execution_id: ^execution_3, group_id: ^group_3},
               %ExecutionResult{
                 execution_id: ^execution_id,
                 group_id: ^group_id,
                 payload: %{
                   "result" => "passing",
                   "check_results" => [_ | _]
                 }
               }
             ] = Repo.all(ExecutionResult)
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

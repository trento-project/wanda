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
        :execution_result,
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
      ] = insert_list(3, :result)

      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()

      build(
        :execution_result,
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
end

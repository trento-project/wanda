defmodule Wanda.ResultsTest do
  use ExUnit.Case
  use Wanda.DataCase

  import Wanda.Factory

  alias Wanda.Catalog
  alias Wanda.Results

  alias Wanda.Execution.{
    Evaluation,
    ExecutionResult,
    Fact
  }

  describe "Appending Execution Results to the history log" do
    test "should correctly add an item to an empty log" do
      gathered_facts = %{
        "expect_check" => %{
          "agent_1" => [
            %Fact{name: "corosync_token_timeout", check_id: "expect_check", value: 30_000}
          ]
        }
      }

      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      checks = [Catalog.get_check("expect_check")]

      result = Evaluation.execute(execution_id, group_id, checks, gathered_facts)

      Results.append(result)

      history_log = Repo.all(ExecutionResult)
      assert 1 == length(history_log)

      assert [
               %ExecutionResult{
                 execution_id: ^execution_id,
                 group_id: ^group_id,
                 payload: %{
                   "result" => "passing",
                   "execution_id" => ^execution_id,
                   "group_id" => ^group_id,
                   "check_results" => [_ | _]
                 }
               }
             ] = history_log
    end

    test "should correctly add an item to a non empty log" do
      [
        %ExecutionResult{execution_id: execution_1, group_id: group_1},
        %ExecutionResult{execution_id: execution_2, group_id: group_2},
        %ExecutionResult{execution_id: execution_3, group_id: group_3}
      ] = insert_list(3, :execution_result_log_item)

      gathered_facts = %{
        "expect_check" => %{
          "agent_1" => [
            %Fact{name: "corosync_token_timeout", check_id: "expect_check", value: 30_000}
          ]
        }
      }

      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      checks = [Catalog.get_check("expect_check")]

      result = Evaluation.execute(execution_id, group_id, checks, gathered_facts)

      Results.append(result)

      history_log = Repo.all(ExecutionResult)
      assert 4 == length(history_log)

      assert [
               %ExecutionResult{execution_id: ^execution_1, group_id: ^group_1},
               %ExecutionResult{execution_id: ^execution_2, group_id: ^group_2},
               %ExecutionResult{execution_id: ^execution_3, group_id: ^group_3},
               %ExecutionResult{
                 execution_id: ^execution_id,
                 group_id: ^group_id,
                 payload: %{
                   "result" => "passing",
                   "execution_id" => ^execution_id,
                   "group_id" => ^group_id,
                   "check_results" => [_ | _]
                 }
               }
             ] = history_log
    end
  end
end

defmodule Wanda.Executions.FakeEvaluationTest do
  use ExUnit.Case
  use Wanda.DataCase

  import Wanda.Factory

  alias Wanda.Catalog.Check

  alias Wanda.Executions.{
    Execution,
    FakeEvaluation,
    Result,
    Target
  }

  describe "create_fake_execution/3" do
    test "creates a fake execution" do
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

      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()

      assert %Execution{
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
             } = FakeEvaluation.create_fake_execution(execution_id, group_id, targets)
    end
  end

  describe "complete_fake_execution/4" do
    test "should complete a running fake execution" do
      [
        %Check{
          id: check_id_1
        },
        %Check{
          id: check_id_2
        }
      ] = checks = build_list(2, :check)

      [
        %Execution.Target{
          agent_id: agent_id_1
        }
      ] = execution_targets = build_list(1, :execution_target, checks: [check_id_1, check_id_2])

      targets = build_list(1, :target, agent_id: agent_id_1, checks: [check_id_1, check_id_2])

      %Execution{
        execution_id: execution_id,
        group_id: group_id,
        targets: execution_targets
      } = insert(:execution, status: :running)

      assert %Result{
               execution_id: ^execution_id,
               group_id: ^group_id
             } =
               FakeEvaluation.complete_fake_execution(
                 execution_id,
                 group_id,
                 targets,
                 checks
               )
    end
  end
end

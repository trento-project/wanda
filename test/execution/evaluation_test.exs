defmodule Wanda.Execution.EvaluationTest do
  use ExUnit.Case

  alias Wanda.Execution.{
    AgentCheckResult,
    CheckResult,
    Evaluation,
    ExpectationEvaluation,
    ExpectationEvaluationError,
    ExpectationResult,
    Result
  }

  describe "evaluation of an execution" do
    test "should return a passing result when all the agents fullfill the expectations with an expect condition" do
      gathered_facts = %{
        "expect_check" => %{
          "agent_1" => %{
            "corosync_token_timeout" => 30_000
          },
          "agent_2" => %{
            "corosync_token_timeout" => 30_000
          }
        }
      }

      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()

      assert %Result{
               execution_id: ^execution_id,
               group_id: ^group_id,
               check_results: [
                 %CheckResult{
                   agents_check_results: [
                     %AgentCheckResult{
                       agent_id: "agent_1",
                       expectation_evaluations: [
                         %ExpectationEvaluation{
                           name: "timeout",
                           return_value: true,
                           type: :expect
                         }
                       ],
                       facts: %{"corosync_token_timeout" => 30_000}
                     },
                     %AgentCheckResult{
                       agent_id: "agent_2",
                       expectation_evaluations: [
                         %ExpectationEvaluation{
                           name: "timeout",
                           return_value: true,
                           type: :expect
                         }
                       ],
                       facts: %{"corosync_token_timeout" => 30_000}
                     }
                   ],
                   check_id: "expect_check",
                   expectation_results: [
                     %ExpectationResult{
                       name: "timeout",
                       result: true,
                       type: :expect
                     }
                   ],
                   result: :passing
                 }
               ],
               result: :passing
             } = Evaluation.execute(execution_id, group_id, gathered_facts)
    end

    test "should return a passing result when all the agents fullfill the expectations with an expect_same condition" do
      gathered_facts = %{
        "expect_same_check" => %{
          "agent_1" => %{
            "corosync_token_timeout" => 30_000
          },
          "agent_2" => %{
            "corosync_token_timeout" => 30_000
          }
        }
      }

      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()

      assert %Result{
               execution_id: ^execution_id,
               group_id: ^group_id,
               check_results: [
                 %CheckResult{
                   agents_check_results: [
                     %AgentCheckResult{
                       agent_id: "agent_1",
                       expectation_evaluations: [
                         %ExpectationEvaluation{
                           name: "timeout",
                           return_value: 30_000,
                           type: :expect_same
                         }
                       ],
                       facts: %{"corosync_token_timeout" => 30_000}
                     },
                     %AgentCheckResult{
                       agent_id: "agent_2",
                       expectation_evaluations: [
                         %ExpectationEvaluation{
                           name: "timeout",
                           return_value: 30_000,
                           type: :expect_same
                         }
                       ],
                       facts: %{"corosync_token_timeout" => 30_000}
                     }
                   ],
                   check_id: "expect_same_check",
                   expectation_results: [
                     %ExpectationResult{
                       name: "timeout",
                       result: true,
                       type: :expect_same
                     }
                   ],
                   result: :passing
                 }
               ],
               result: :passing
             } = Evaluation.execute(execution_id, group_id, gathered_facts)
    end

    test "should return a critical result if a fact is missing from the agent fact gathering" do
      gathered_facts = %{
        "with_fact_missing_check" => %{
          "agent_1" => %{
            "corosync_token_timeout" => 30_000
          },
          "agent_2" => %{}
        }
      }

      assert %Result{
               result: :critical,
               check_results: [
                 %CheckResult{
                   result: :critical,
                   check_id: "with_fact_missing_check",
                   agents_check_results: [
                     _,
                     %AgentCheckResult{
                       agent_id: "agent_2",
                       expectation_evaluations: [
                         %ExpectationEvaluationError{
                           name: "fact_missing",
                           type: :fact_missing_error
                         }
                       ],
                       facts: %{}
                     }
                   ],
                   expectation_results: [
                     %ExpectationResult{
                       name: "fact_missing",
                       result: false,
                       type: :expect
                     }
                   ]
                 }
               ]
             } = Evaluation.execute(UUID.uuid4(), UUID.uuid4(), gathered_facts)
    end
  end
end

defmodule Wanda.Executions.FakeEvaluationTest do
  use ExUnit.Case

  import Wanda.Factory

  alias Wanda.Catalog.{
    Check,
    Fact,
    Value,
    Expectation
  }

  alias Wanda.Executions.{
    CheckResult,
    Execution,
    FakeEvaluation,
    Result
  }

  describe "complete_fake_execution/4" do
    test "should complete a running fake execution" do
      [
        %Fact{
          name: fact_name_1
        },
        %Fact{
          name: fact_name_2
        }
      ] = catalog_facts = build_list(2, :catalog_fact)

      [
        %Value{
          name: value_name_1
        },
        %Value{
          name: value_name_2
        }
      ] = values = build_list(2, :catalog_value)

      [
        %Expectation{name: expectation_name_1},
        %Expectation{name: expectation_name_2}
      ] =
        expectations = [
          build(:catalog_expectation, type: :expect),
          build(:catalog_expectation, type: :expect_same)
        ]

      [
        %Check{
          id: check_id_1
        },
        %Check{
          id: check_id_2
        }
      ] =
        checks =
        build_list(2, :check, facts: catalog_facts, values: values, expectations: expectations)

      [
        %Execution.Target{
          agent_id: agent_id_1
        },
        %Execution.Target{
          agent_id: agent_id_2
        }
      ] = build_list(2, :execution_target, checks: [check_id_1, check_id_2])

      targets = [
        build(:target, agent_id: agent_id_1, checks: [check_id_1, check_id_2]),
        build(:target, agent_id: agent_id_2, checks: [check_id_1, check_id_2])
      ]

      %Execution{
        execution_id: execution_id,
        group_id: group_id
      } = build(:execution, status: :running)

      assert %Result{
               execution_id: ^execution_id,
               group_id: ^group_id,
               check_results: [
                 %CheckResult{
                   check_id: ^check_id_1,
                   agents_check_results: [
                     %Wanda.Executions.AgentCheckResult{
                       agent_id: ^agent_id_1,
                       expectation_evaluations: [
                         %Wanda.Executions.ExpectationEvaluation{
                           name: ^expectation_name_1,
                           type: :expect
                         },
                         %Wanda.Executions.ExpectationEvaluation{
                           name: ^expectation_name_2,
                           type: :expect_same
                         }
                       ],
                       facts: [
                         %Wanda.Executions.Fact{
                           name: ^fact_name_1,
                           check_id: ^check_id_1
                         },
                         %Wanda.Executions.Fact{
                           name: ^fact_name_2,
                           check_id: ^check_id_1
                         }
                       ],
                       values: [
                         %{
                           name: ^value_name_1
                         },
                         %{
                           name: ^value_name_2
                         }
                       ]
                     },
                     %Wanda.Executions.AgentCheckResult{
                       agent_id: ^agent_id_2,
                       expectation_evaluations: [
                         %Wanda.Executions.ExpectationEvaluation{
                           name: ^expectation_name_1,
                           type: :expect
                         },
                         %Wanda.Executions.ExpectationEvaluation{
                           name: ^expectation_name_2,
                           type: :expect_same
                         }
                       ],
                       facts: [
                         %Wanda.Executions.Fact{
                           name: ^fact_name_1,
                           check_id: ^check_id_1
                         },
                         %Wanda.Executions.Fact{
                           name: ^fact_name_2,
                           check_id: ^check_id_1
                         }
                       ],
                       values: [
                         %{
                           name: ^value_name_1
                         },
                         %{
                           name: ^value_name_2
                         }
                       ]
                     }
                   ],
                   expectation_results: [
                     %Wanda.Executions.ExpectationResult{
                       name: ^expectation_name_1,
                       type: :expect
                     },
                     %Wanda.Executions.ExpectationResult{
                       name: ^expectation_name_2,
                       type: :expect_same
                     }
                   ]
                 },
                 %CheckResult{
                   check_id: ^check_id_2,
                   agents_check_results: [
                     %Wanda.Executions.AgentCheckResult{
                       agent_id: ^agent_id_1,
                       facts: [
                         %Wanda.Executions.Fact{
                           name: ^fact_name_1,
                           check_id: ^check_id_2
                         },
                         %Wanda.Executions.Fact{
                           name: ^fact_name_2,
                           check_id: ^check_id_2
                         }
                       ],
                       values: [
                         %{
                           name: ^value_name_1
                         },
                         %{
                           name: ^value_name_2
                         }
                       ]
                     },
                     %Wanda.Executions.AgentCheckResult{
                       agent_id: ^agent_id_2,
                       facts: [
                         %Wanda.Executions.Fact{
                           name: ^fact_name_1,
                           check_id: ^check_id_2
                         },
                         %Wanda.Executions.Fact{
                           name: ^fact_name_2,
                           check_id: ^check_id_2
                         }
                       ],
                       values: [
                         %{
                           name: ^value_name_1
                         },
                         %{
                           name: ^value_name_2
                         }
                       ]
                     }
                   ],
                   expectation_results: [
                     %Wanda.Executions.ExpectationResult{
                       name: ^expectation_name_1,
                       type: :expect
                     },
                     %Wanda.Executions.ExpectationResult{
                       name: ^expectation_name_2,
                       type: :expect_same
                     }
                   ]
                 }
               ]
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

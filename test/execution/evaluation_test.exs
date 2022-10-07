defmodule Wanda.Execution.EvaluationTest do
  use ExUnit.Case

  import Wanda.Factory

  alias Wanda.Catalog

  alias Wanda.Execution.{
    AgentCheckError,
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
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      fact_value = Enum.random(1..10)

      [%Catalog.Fact{name: fact_name}] = catalog_facts = build_list(1, :catalog_fact)

      [%Catalog.Expectation{name: expectation_name}] =
        expectations =
        build_list(1, :catalog_expectation,
          type: :expect,
          expression: "#{fact_name} == #{fact_value}"
        )

      [%Catalog.Check{id: check_id}] =
        checks =
        build_list(1, :check, facts: catalog_facts, values: [], expectations: expectations)

      facts = build_list(1, :fact, name: fact_name, check_id: check_id, value: fact_value)

      gathered_facts = %{
        check_id => %{
          "agent_1" => facts,
          "agent_2" => facts
        }
      }

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
                           name: ^expectation_name,
                           return_value: true,
                           type: :expect
                         }
                       ],
                       facts: ^facts
                     },
                     %AgentCheckResult{
                       agent_id: "agent_2",
                       expectation_evaluations: [
                         %ExpectationEvaluation{
                           name: ^expectation_name,
                           return_value: true,
                           type: :expect
                         }
                       ],
                       facts: ^facts
                     }
                   ],
                   check_id: ^check_id,
                   expectation_results: [
                     %ExpectationResult{
                       name: ^expectation_name,
                       result: true,
                       type: :expect
                     }
                   ],
                   result: :passing
                 }
               ],
               result: :passing
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts)
    end

    test "should return a critical result when not all the agents fullfill the expectations with an expect condition" do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      fact_value = Enum.random(1..10)
      incorrect_fact_value = Enum.random(11..20)

      [%Catalog.Fact{name: fact_name}] = catalog_facts = build_list(1, :catalog_fact)

      [%Catalog.Expectation{name: expectation_name}] =
        expectations =
        build_list(1, :catalog_expectation,
          type: :expect,
          expression: "#{fact_name} == #{fact_value}"
        )

      [%Catalog.Check{id: check_id}] =
        checks =
        build_list(1, :check,
          severity: :critical,
          facts: catalog_facts,
          values: [],
          expectations: expectations
        )

      gathered_facts = %{
        check_id => %{
          "agent_1" =>
            incorrect_facts =
              build_list(1, :fact,
                name: fact_name,
                check_id: check_id,
                value: incorrect_fact_value
              ),
          "agent_2" =>
            facts = build_list(1, :fact, name: fact_name, check_id: check_id, value: fact_value)
        }
      }

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
                           name: ^expectation_name,
                           return_value: false,
                           type: :expect
                         }
                       ],
                       facts: ^incorrect_facts
                     },
                     %AgentCheckResult{
                       agent_id: "agent_2",
                       expectation_evaluations: [
                         %ExpectationEvaluation{
                           name: ^expectation_name,
                           return_value: true,
                           type: :expect
                         }
                       ],
                       facts: ^facts
                     }
                   ],
                   check_id: ^check_id,
                   expectation_results: [
                     %ExpectationResult{
                       name: ^expectation_name,
                       result: false,
                       type: :expect
                     }
                   ],
                   result: :critical
                 }
               ],
               result: :critical
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts)
    end

    test "should return a critical result when some agent gets fact gathering errors" do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      fact_value = Enum.random(1..10)

      [%Catalog.Fact{name: fact_name}] = catalog_facts = build_list(1, :catalog_fact)

      [%Catalog.Expectation{name: expectation_name}] =
        expectations =
        build_list(1, :catalog_expectation,
          type: :expect,
          expression: "#{fact_name} == #{fact_value}"
        )

      [%Catalog.Check{id: check_id}] =
        checks =
        build_list(1, :check,
          severity: :critical,
          facts: catalog_facts,
          values: [],
          expectations: expectations
        )

      gathered_facts = %{
        check_id => %{
          "agent_1" =>
            facts = build_list(1, :fact, name: fact_name, check_id: check_id, value: fact_value),
          "agent_2" =>
            facts_with_errors = build_list(1, :fact_error, name: fact_name, check_id: check_id)
        }
      }

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
                           name: ^expectation_name,
                           return_value: true,
                           type: :expect
                         }
                       ],
                       facts: ^facts
                     },
                     %AgentCheckError{
                       agent_id: "agent_2",
                       facts: ^facts_with_errors,
                       message: "Fact gathering ocurred during the execution",
                       type: :fact_gathering_error
                     }
                   ],
                   check_id: ^check_id,
                   expectation_results: [
                     %ExpectationResult{
                       name: ^expectation_name,
                       result: true,
                       type: :expect
                     }
                   ],
                   result: :critical
                 }
               ],
               result: :critical
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts)
    end

    test "should return a passing result when all the agents fullfill the expectations with an expect_same condition" do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      fact_value = Enum.random(1..10)

      [%Catalog.Fact{name: fact_name}] = catalog_facts = build_list(1, :catalog_fact)

      [%Catalog.Expectation{name: expectation_name}] =
        expectations =
        build_list(1, :catalog_expectation,
          type: :expect_same,
          expression: "#{fact_name} == #{fact_value}"
        )

      [%Catalog.Check{id: check_id}] =
        checks =
        build_list(1, :check,
          facts: catalog_facts,
          values: [],
          expectations: expectations
        )

      facts = build_list(1, :fact, name: fact_name, check_id: check_id, value: fact_value)

      gathered_facts = %{
        check_id => %{
          "agent_1" => facts,
          "agent_2" => facts
        }
      }

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
                           name: ^expectation_name,
                           return_value: true,
                           type: :expect_same
                         }
                       ],
                       facts: ^facts
                     },
                     %AgentCheckResult{
                       agent_id: "agent_2",
                       expectation_evaluations: [
                         %ExpectationEvaluation{
                           name: ^expectation_name,
                           return_value: true,
                           type: :expect_same
                         }
                       ],
                       facts: ^facts
                     }
                   ],
                   check_id: ^check_id,
                   expectation_results: [
                     %ExpectationResult{
                       name: ^expectation_name,
                       result: true,
                       type: :expect_same
                     }
                   ],
                   result: :passing
                 }
               ],
               result: :passing
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts)
    end

    test "should return a passing result when not all the agents fullfill the expectations with an expect_same condition" do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      fact_value = Enum.random(1..10)
      incorrect_fact_value = Enum.random(11..20)

      [%Catalog.Fact{name: fact_name}] = catalog_facts = build_list(1, :catalog_fact)

      [%Catalog.Expectation{name: expectation_name}] =
        expectations =
        build_list(1, :catalog_expectation,
          type: :expect_same,
          expression: "#{fact_name} == #{fact_value}"
        )

      [%Catalog.Check{id: check_id}] =
        checks =
        build_list(1, :check,
          severity: :critical,
          facts: catalog_facts,
          values: [],
          expectations: expectations
        )

      gathered_facts = %{
        check_id => %{
          "agent_1" =>
            facts = build_list(1, :fact, name: fact_name, check_id: check_id, value: fact_value),
          "agent_2" =>
            incorrect_facts =
              build_list(1, :fact,
                name: fact_name,
                check_id: check_id,
                value: incorrect_fact_value
              )
        }
      }

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
                           name: ^expectation_name,
                           return_value: true,
                           type: :expect_same
                         }
                       ],
                       facts: ^facts
                     },
                     %AgentCheckResult{
                       agent_id: "agent_2",
                       expectation_evaluations: [
                         %ExpectationEvaluation{
                           name: ^expectation_name,
                           return_value: false,
                           type: :expect_same
                         }
                       ],
                       facts: ^incorrect_facts
                     }
                   ],
                   check_id: ^check_id,
                   expectation_results: [
                     %ExpectationResult{
                       name: ^expectation_name,
                       result: false,
                       type: :expect_same
                     }
                   ],
                   result: :critical
                 }
               ],
               result: :critical
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts)
    end

    test "should return a critical result if a fact is missing from the agent fact gathering" do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      fact_value = Enum.random(1..10)

      [%Catalog.Fact{name: fact_name}] = catalog_facts = build_list(1, :catalog_fact)

      [%Catalog.Expectation{name: expectation_name}] =
        expectations =
        build_list(1, :catalog_expectation,
          type: :expect,
          expression: "#{fact_name} == #{fact_value}"
        )

      [%Catalog.Check{id: check_id}] =
        checks =
        build_list(1, :check,
          severity: :critical,
          facts: catalog_facts,
          values: [],
          expectations: expectations
        )

      gathered_facts = %{
        check_id => %{
          "agent_1" =>
            build_list(1, :fact, name: fact_name, check_id: check_id, value: fact_value),
          "agent_2" => []
        }
      }

      assert %Result{
               result: :critical,
               check_results: [
                 %CheckResult{
                   result: :critical,
                   check_id: ^check_id,
                   agents_check_results: [
                     _,
                     %AgentCheckResult{
                       agent_id: "agent_2",
                       expectation_evaluations: [
                         %ExpectationEvaluationError{
                           name: ^expectation_name,
                           type: :fact_missing_error
                         }
                       ],
                       facts: []
                     }
                   ],
                   expectation_results: [
                     %ExpectationResult{
                       name: ^expectation_name,
                       result: false,
                       type: :expect
                     }
                   ]
                 }
               ]
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts)
    end

    test "should return a critical result if an illegal expression was specified in a check expectation" do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()

      [%Catalog.Fact{name: fact_name}] = catalog_facts = build_list(1, :catalog_fact)

      [%Catalog.Expectation{name: expectation_name}] =
        expectations = build_list(1, :catalog_expectation, type: :expect)

      [%Catalog.Check{id: check_id}] =
        checks =
        build_list(1, :check,
          severity: :critical,
          facts: catalog_facts,
          values: [],
          expectations: expectations
        )

      facts = build_list(1, :fact, name: fact_name, check_id: check_id)

      gathered_facts = %{
        check_id => %{
          "agent_1" => facts,
          "agent_2" => facts
        }
      }

      assert %Result{
               result: :critical,
               check_results: [
                 %CheckResult{
                   result: :critical,
                   check_id: ^check_id,
                   agents_check_results: [
                     %AgentCheckResult{
                       agent_id: "agent_1",
                       expectation_evaluations: [
                         %ExpectationEvaluationError{
                           name: ^expectation_name,
                           type: :illegal_expression_error
                         }
                       ]
                     },
                     %AgentCheckResult{
                       agent_id: "agent_2",
                       expectation_evaluations: [
                         %ExpectationEvaluationError{
                           name: ^expectation_name,
                           type: :illegal_expression_error
                         }
                       ]
                     }
                   ],
                   expectation_results: [
                     %ExpectationResult{
                       name: ^expectation_name,
                       result: false,
                       type: :expect
                     }
                   ]
                 }
               ]
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts)
    end

    test "should return a critical result if an agent times out" do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      fact_value = Enum.random(1..10)

      [%Catalog.Fact{name: fact_name}] = catalog_facts = build_list(1, :catalog_fact)

      [%Catalog.Expectation{name: expectation_name}] =
        expectations =
        build_list(1, :catalog_expectation,
          type: :expect,
          expression: "#{fact_name} == #{fact_value}"
        )

      [%Catalog.Check{id: check_id}] =
        checks =
        build_list(1, :check,
          severity: :critical,
          facts: catalog_facts,
          values: [],
          expectations: expectations
        )

      facts = build_list(1, :fact, name: fact_name, check_id: check_id, value: fact_value)

      gathered_facts = %{
        check_id => %{
          "agent_1" => facts,
          "agent_2" => facts,
          "agent_3" => :timeout
        }
      }

      assert %Result{
               execution_id: ^execution_id,
               group_id: ^group_id,
               check_results: [
                 %CheckResult{
                   agents_check_results: [
                     _,
                     _,
                     %AgentCheckError{
                       agent_id: "agent_3",
                       message: "Agent timed out during the execution",
                       type: :timeout
                     }
                   ],
                   check_id: ^check_id,
                   expectation_results: [
                     %ExpectationResult{
                       name: ^expectation_name,
                       result: true,
                       type: :expect
                     }
                   ],
                   result: :critical
                 }
               ],
               result: :critical
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts)
    end

    test "should return warning result if the check severity is specified as warning" do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()

      [%Catalog.Fact{name: fact_name}] = catalog_facts = build_list(1, :catalog_fact)

      expectations = build_list(1, :catalog_expectation, type: :expect)

      [%Catalog.Check{id: check_id}] =
        checks =
        build_list(1, :check,
          severity: :warning,
          facts: catalog_facts,
          values: [],
          expectations: expectations
        )

      facts = build_list(1, :fact, name: fact_name, check_id: check_id)

      gathered_facts = %{
        check_id => %{
          "agent_1" => facts,
          "agent_2" => facts
        }
      }

      assert %Result{
               execution_id: ^execution_id,
               group_id: ^group_id,
               check_results: [
                 %CheckResult{
                   result: :warning
                 }
               ],
               result: :warning
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts)
    end
  end
end

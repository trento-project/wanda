defmodule Wanda.Executions.EvaluationTest do
  use ExUnit.Case

  import Wanda.Factory

  alias Wanda.{Catalog, EvaluationEngine}

  alias Wanda.Executions.{
    AgentCheckError,
    AgentCheckResult,
    CheckResult,
    Evaluation,
    ExpectationEvaluation,
    ExpectationEvaluationError,
    ExpectationResult,
    Fact,
    Result,
    Value
  }

  setup do
    engine = EvaluationEngine.new()

    {:ok, %{engine: engine}}
  end

  describe "evaluation of an execution" do
    test "should return a passing result when all the agents fullfill the expectations with an expect condition",
         %{engine: engine} do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      fact_value = Enum.random(1..10)

      [%Catalog.Fact{name: fact_name}] = catalog_facts = build_list(1, :catalog_fact)

      [%Catalog.Expectation{name: expectation_name}] =
        expectations =
        build_list(1, :catalog_expectation,
          type: :expect,
          expression: "facts.#{fact_name} == #{fact_value}"
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
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts, %{}, engine)
    end

    test "should return a critical result when not all the agents fullfill the expectations with an expect condition",
         %{engine: engine} do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      fact_value = Enum.random(1..10)
      incorrect_fact_value = Enum.random(11..20)

      [%Catalog.Fact{name: fact_name}] = catalog_facts = build_list(1, :catalog_fact)

      [%Catalog.Expectation{name: expectation_name}] =
        expectations =
        build_list(1, :catalog_expectation,
          type: :expect,
          expression: "facts.#{fact_name} == #{fact_value}"
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
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts, %{}, engine)
    end

    test "should return a critical result when some agent gets fact gathering errors", %{
      engine: engine
    } do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      fact_value = Enum.random(1..10)

      [%Catalog.Fact{name: fact_name}] = catalog_facts = build_list(1, :catalog_fact)

      [%Catalog.Expectation{name: expectation_name}] =
        expectations =
        build_list(1, :catalog_expectation,
          type: :expect,
          expression: "facts.#{fact_name} == #{fact_value}"
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
                       message: "Fact gathering error occurred during the execution",
                       type: :fact_gathering_error
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
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts, %{}, engine)
    end

    test "should return a passing result when all the agents fullfill the expectations with an expect_same condition",
         %{engine: engine} do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      fact_value = Enum.random(1..10)

      [%Catalog.Fact{name: fact_name}] = catalog_facts = build_list(1, :catalog_fact)

      [%Catalog.Expectation{name: expectation_name}] =
        expectations =
        build_list(1, :catalog_expectation,
          type: :expect_same,
          expression: "facts.#{fact_name} == #{fact_value}"
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
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts, %{}, engine)
    end

    test "should return a critical result when some of the agents expect_same condition return value is different",
         %{engine: engine} do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      fact_value = Enum.random(1..10)
      incorrect_fact_value = Enum.random(11..20)

      [%Catalog.Fact{name: fact_name}] = catalog_facts = build_list(1, :catalog_fact)

      [%Catalog.Expectation{name: expectation_name}] =
        expectations =
        build_list(1, :catalog_expectation,
          type: :expect_same,
          expression: "facts.#{fact_name} == #{fact_value}"
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
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts, %{}, engine)
    end

    test "should return a critical result if a fact is missing from the agent fact gathering", %{
      engine: engine
    } do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      fact_value = Enum.random(1..10)

      [%Catalog.Fact{name: fact_name}] = catalog_facts = build_list(1, :catalog_fact)

      [%Catalog.Expectation{name: expectation_name}] =
        expectations =
        build_list(1, :catalog_expectation,
          type: :expect,
          expression: "facts.#{fact_name} == #{fact_value}"
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
                           type: :property_not_found
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
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts, %{}, engine)
    end

    test "should return a critical result if an illegal expression was specified in a check expectation",
         %{engine: engine} do
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
                           type: :parsing
                         }
                       ]
                     },
                     %AgentCheckResult{
                       agent_id: "agent_2",
                       expectation_evaluations: [
                         %ExpectationEvaluationError{
                           name: ^expectation_name,
                           type: :parsing
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
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts, %{}, engine)
    end

    test "should return a critical result if an agent times out", %{engine: engine} do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      fact_value = Enum.random(1..10)

      [%Catalog.Fact{name: fact_name}] = catalog_facts = build_list(1, :catalog_fact)

      [%Catalog.Expectation{name: expectation_name}] =
        expectations =
        build_list(1, :catalog_expectation,
          type: :expect,
          expression: "facts.#{fact_name} == #{fact_value}"
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
                       result: false,
                       type: :expect
                     }
                   ],
                   result: :critical
                 }
               ],
               result: :critical
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts, %{}, engine)
    end

    test "should return warning result if the check severity is specified as warning", %{
      engine: engine
    } do
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
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts, %{}, engine)
    end

    test "should return a critical result if an agent times out and severity is warning", %{
      engine: engine
    } do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()

      [%Catalog.Fact{name: fact_name}] = catalog_facts = build_list(1, :catalog_fact)

      expectations = build_list(1, :catalog_expectation, type: :expect, expression: "1 == 1")

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
          "agent_2" => :timeout
        }
      }

      assert %Result{
               execution_id: ^execution_id,
               group_id: ^group_id,
               check_results: [
                 %CheckResult{
                   check_id: ^check_id,
                   result: :critical
                 }
               ],
               result: :critical
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts, %{}, engine)
    end
  end

  describe "expect_enum" do
    test "should weight properly the return values", %{engine: engine} do
      [
        %Catalog.Fact{name: fact_1_name},
        %Catalog.Fact{name: fact_2_name}
      ] = catalog_facts = build_list(2, :catalog_fact)

      expression_1 = """
      if facts.#{fact_1_name} == 10 {
        "passing"
      } else if facts.#{fact_1_name} == 5 {
        "warning"
      }
      """

      expression_2 = """
      if facts.#{fact_2_name} == 20 {
        "passing"
      } else if facts.#{fact_2_name} == 15 {
        "warning"
      }
      """

      scenarios = [
        %{
          facts: [
            %{agent_1: 10, agent_2: 10},
            %{agent_1: 20, agent_2: 20}
          ],
          expectation_1_result: :passing,
          expectation_2_result: :passing,
          result: :passing
        },
        %{
          facts: [
            %{agent_1: 5, agent_2: 10},
            %{agent_1: 20, agent_2: 20}
          ],
          expectation_1_result: :warning,
          expectation_2_result: :passing,
          result: :warning
        },
        %{
          facts: [
            %{agent_1: 3, agent_2: 10},
            %{agent_1: 20, agent_2: 20}
          ],
          expectation_1_result: :critical,
          expectation_2_result: :passing,
          result: :critical
        },
        %{
          facts: [
            %{agent_1: 3, agent_2: 10},
            %{agent_1: 20, agent_2: 15}
          ],
          expectation_1_result: :critical,
          expectation_2_result: :warning,
          result: :critical
        }
      ]

      Enum.each(scenarios, fn %{
                                facts: [
                                  %{
                                    agent_1: agent_1_fact_1_value,
                                    agent_2: agent_2_fact_1_value
                                  },
                                  %{
                                    agent_1: agent_1_fact_2_value,
                                    agent_2: agent_2_fact_2_value
                                  }
                                ],
                                expectation_1_result: expectation_1_result,
                                expectation_2_result: expectation_2_result,
                                result: result
                              } ->
        expectations = [
          build(:catalog_expectation,
            name: "expectation_1",
            type: :expect_enum,
            expression: expression_1
          ),
          build(:catalog_expectation,
            name: "expectation_2",
            type: :expect_enum,
            expression: expression_2
          )
        ]

        [%Catalog.Check{id: check_id}] =
          checks =
          build_list(1, :check, facts: catalog_facts, values: [], expectations: expectations)

        facts_agent_1 = [
          build(:fact, name: fact_1_name, check_id: check_id, value: agent_1_fact_1_value),
          build(:fact, name: fact_2_name, check_id: check_id, value: agent_1_fact_2_value)
        ]

        facts_agent_2 = [
          build(:fact, name: fact_1_name, check_id: check_id, value: agent_2_fact_1_value),
          build(:fact, name: fact_2_name, check_id: check_id, value: agent_2_fact_2_value)
        ]

        gathered_facts = %{
          check_id => %{
            "agent_1" => facts_agent_1,
            "agent_2" => facts_agent_2
          }
        }

        assert %Result{
                 result: ^result,
                 check_results: [
                   %CheckResult{
                     result: ^result,
                     expectation_results: [
                       %ExpectationResult{
                         name: "expectation_1",
                         result: ^expectation_1_result,
                         type: :expect_enum
                       },
                       %ExpectationResult{
                         name: "expectation_2",
                         result: ^expectation_2_result,
                         type: :expect_enum
                       }
                     ]
                   }
                 ]
               } =
                 Evaluation.execute(
                   UUID.uuid4(),
                   UUID.uuid4(),
                   checks,
                   gathered_facts,
                   %{},
                   engine
                 )
      end)
    end

    test "should set to critical unknown return values", %{engine: engine} do
      [%Catalog.Fact{name: fact_name}] = catalog_facts = build_list(1, :catalog_fact)

      expectations =
        build_list(1, :catalog_expectation,
          name: "some_expectation",
          type: :expect_enum,
          expression: """
          if facts.#{fact_name} == "unknown" {
            "unknown"
          }
          """
        )

      [%Catalog.Check{id: check_id}] =
        checks =
        build_list(1, :check, facts: catalog_facts, values: [], expectations: expectations)

      facts = build_list(1, :fact, name: fact_name, check_id: check_id, value: "unknown")

      gathered_facts = %{
        check_id => %{
          "agent" => facts
        }
      }

      assert %Result{
               result: :critical,
               check_results: [
                 %CheckResult{
                   result: :critical,
                   agents_check_results: [
                     %AgentCheckResult{
                       expectation_evaluations: [
                         %ExpectationEvaluation{
                           name: "some_expectation",
                           return_value: :critical,
                           type: :expect_enum,
                           failure_message: "Expectation not met"
                         }
                       ]
                     }
                   ],
                   expectation_results: [
                     %ExpectationResult{
                       name: "some_expectation",
                       result: :critical,
                       type: :expect_enum
                     }
                   ]
                 }
               ]
             } =
               Evaluation.execute(UUID.uuid4(), UUID.uuid4(), checks, gathered_facts, %{}, engine)
    end

    test "should interpolate the correct failure message", %{engine: engine} do
      [%Catalog.Fact{name: fact_name}] = catalog_facts = build_list(1, :catalog_fact)
      fact_value = 10

      scenarios = [
        %{
          return_value: :warning,
          message: "warning message: fact value #{fact_value}"
        },
        %{
          return_value: :critical,
          message: "failure message: fact value #{fact_value}"
        }
      ]

      Enum.each(scenarios, fn %{return_value: return_value, message: message} ->
        expectations =
          build_list(1, :catalog_expectation,
            name: "some_expectation",
            type: :expect_enum,
            expression: """
            if facts.#{fact_name} == #{fact_value} {
              "#{Atom.to_string(return_value)}"
            }
            """,
            warning_message: "warning message: fact value ${facts.#{fact_name}}",
            failure_message: "failure message: fact value ${facts.#{fact_name}}"
          )

        [%Catalog.Check{id: check_id}] =
          checks =
          build_list(1, :check, facts: catalog_facts, values: [], expectations: expectations)

        facts = build_list(1, :fact, name: fact_name, check_id: check_id, value: fact_value)

        gathered_facts = %{
          check_id => %{
            "agent" => facts
          }
        }

        assert %Result{
                 result: ^return_value,
                 check_results: [
                   %CheckResult{
                     result: ^return_value,
                     agents_check_results: [
                       %AgentCheckResult{
                         expectation_evaluations: [
                           %ExpectationEvaluation{
                             name: "some_expectation",
                             return_value: ^return_value,
                             type: :expect_enum,
                             failure_message: ^message
                           }
                         ]
                       }
                     ],
                     expectation_results: [
                       %ExpectationResult{
                         name: "some_expectation",
                         result: ^return_value,
                         type: :expect_enum
                       }
                     ]
                   }
                 ]
               } =
                 Evaluation.execute(
                   UUID.uuid4(),
                   UUID.uuid4(),
                   checks,
                   gathered_facts,
                   %{},
                   engine
                 )
      end)
    end
  end

  describe "expressions with arrays" do
    test "should return a passing result", %{engine: engine} do
      [value | _] =
        array =
        1..10
        |> Enum.random()
        |> Faker.Util.list(fn _ -> Faker.StarWars.character() end)
        |> Enum.uniq()

      [%Catalog.Fact{name: fact_name}] = catalog_facts = build_list(1, :catalog_fact)

      expectations = [
        build(:catalog_expectation,
          name: "some_expectation",
          type: :expect,
          expression: "facts.#{fact_name}.some(|v| v == \"#{value}\")"
        ),
        build(:catalog_expectation,
          name: "filter_expectation",
          type: :expect_same,
          expression: "facts.#{fact_name}.filter(|v| v == \"#{value}\")"
        )
      ]

      [%Catalog.Check{id: check_id}] =
        checks =
        build_list(1, :check, facts: catalog_facts, values: [], expectations: expectations)

      facts = build_list(1, :fact, name: fact_name, check_id: check_id, value: array)

      gathered_facts = %{
        check_id => %{
          "agent" => facts
        }
      }

      assert %Result{
               result: :passing,
               check_results: [
                 %CheckResult{
                   result: :passing,
                   agents_check_results: [
                     %AgentCheckResult{
                       expectation_evaluations: [
                         %ExpectationEvaluation{
                           name: "some_expectation",
                           return_value: true,
                           type: :expect
                         },
                         %ExpectationEvaluation{
                           name: "filter_expectation",
                           return_value: [^value],
                           type: :expect_same
                         }
                       ]
                     }
                   ],
                   expectation_results: [
                     %ExpectationResult{
                       name: "filter_expectation",
                       result: true,
                       type: :expect_same
                     },
                     %ExpectationResult{
                       name: "some_expectation",
                       result: true,
                       type: :expect
                     }
                   ]
                 }
               ]
             } =
               Evaluation.execute(UUID.uuid4(), UUID.uuid4(), checks, gathered_facts, %{}, engine)
    end
  end

  describe "expression with maps" do
    test "should return a passing result", %{engine: engine} do
      map =
        1..10
        |> Enum.random()
        |> Faker.Util.list(fn index -> {"key_#{index}", Faker.StarWars.character()} end)
        |> Enum.into(%{})

      value = Map.get(map, "key_0")

      [%Catalog.Fact{name: fact_name}] = catalog_facts = build_list(1, :catalog_fact)

      expectations = [
        build(:catalog_expectation,
          name: "property_expectation",
          type: :expect,
          expression: "facts.#{fact_name}.key_0 == \"#{value}\""
        )
      ]

      [%Catalog.Check{id: check_id}] =
        checks =
        build_list(1, :check, facts: catalog_facts, values: [], expectations: expectations)

      facts = build_list(1, :fact, name: fact_name, check_id: check_id, value: map)

      gathered_facts = %{
        check_id => %{
          "agent" => facts
        }
      }

      assert %Result{
               result: :passing,
               check_results: [
                 %CheckResult{
                   result: :passing,
                   expectation_results: [
                     %ExpectationResult{
                       name: "property_expectation",
                       result: true,
                       type: :expect
                     }
                   ]
                 }
               ]
             } =
               Evaluation.execute(UUID.uuid4(), UUID.uuid4(), checks, gathered_facts, %{}, engine)
    end
  end

  describe "environment based check evaluation" do
    setup do
      check =
        build(:check,
          severity: :critical,
          facts: [
            build(:catalog_fact,
              name: "some_fact",
              gatherer: "some_gatherer",
              argument: "some_argument"
            )
          ],
          values: [
            build(:catalog_value,
              name: "some_value",
              default: "a_default_value",
              conditions: [
                build(:catalog_condition,
                  value: "value_on_first_condition",
                  expression: "env.some_env == \"whoa\" || env.some_env == \"yeah\""
                ),
                build(:catalog_condition,
                  value: "value_on_second_condition",
                  expression: "env.some_env == \"yay\""
                )
              ]
            )
          ],
          expectations: [
            build(:catalog_expectation,
              name: "some_expectation",
              type: :expect,
              expression: "facts.some_fact == values.some_value"
            )
          ]
        )

      %{checks: [check]}
    end

    test "should return a passing result based on the first matching environmental condition",
         %{checks: [%{id: check_id}] = checks, engine: engine} do
      gathered_facts = %{
        check_id => %{
          "agent_1" => [
            %Fact{name: "some_fact", check_id: check_id, value: "value_on_first_condition"}
          ],
          "agent_2" => [
            %Fact{name: "some_fact", check_id: check_id, value: "value_on_first_condition"}
          ]
        }
      }

      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()

      expected_result = %Result{
        execution_id: execution_id,
        group_id: group_id,
        check_results: [
          %CheckResult{
            agents_check_results: [
              %AgentCheckResult{
                agent_id: "agent_1",
                expectation_evaluations: [
                  %ExpectationEvaluation{
                    name: "some_expectation",
                    return_value: true,
                    type: :expect
                  }
                ],
                facts: [
                  %Fact{
                    check_id: check_id,
                    name: "some_fact",
                    value: "value_on_first_condition"
                  }
                ],
                values: [
                  %Value{name: "some_value", value: "value_on_first_condition"}
                ]
              },
              %AgentCheckResult{
                agent_id: "agent_2",
                expectation_evaluations: [
                  %ExpectationEvaluation{
                    name: "some_expectation",
                    return_value: true,
                    type: :expect
                  }
                ],
                facts: [
                  %Fact{
                    check_id: check_id,
                    name: "some_fact",
                    value: "value_on_first_condition"
                  }
                ],
                values: [
                  %Value{name: "some_value", value: "value_on_first_condition"}
                ]
              }
            ],
            check_id: check_id,
            expectation_results: [
              %ExpectationResult{
                name: "some_expectation",
                result: true,
                type: :expect
              }
            ],
            result: :passing
          }
        ],
        result: :passing,
        timeout: []
      }

      assert ^expected_result =
               Evaluation.execute(
                 execution_id,
                 group_id,
                 checks,
                 gathered_facts,
                 %{
                   "some_env" => "whoa"
                 },
                 engine
               )

      assert ^expected_result =
               Evaluation.execute(
                 execution_id,
                 group_id,
                 checks,
                 gathered_facts,
                 %{
                   "some_env" => "yeah"
                 },
                 engine
               )
    end

    test "should return a passing result based on the proper environmental conditions matching",
         %{checks: [%{id: check_id}] = checks, engine: engine} do
      env = %{"some_env" => "yay"}

      gathered_facts = %{
        check_id => %{
          "agent_1" => [
            %Fact{name: "some_fact", check_id: check_id, value: "value_on_second_condition"}
          ],
          "agent_2" => [
            %Fact{name: "some_fact", check_id: check_id, value: "value_on_second_condition"}
          ]
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
                           name: "some_expectation",
                           return_value: true,
                           type: :expect
                         }
                       ],
                       facts: [
                         %Fact{
                           check_id: ^check_id,
                           name: "some_fact",
                           value: "value_on_second_condition"
                         }
                       ],
                       values: [
                         %Value{name: "some_value", value: "value_on_second_condition"}
                       ]
                     },
                     %AgentCheckResult{
                       agent_id: "agent_2",
                       expectation_evaluations: [
                         %ExpectationEvaluation{
                           name: "some_expectation",
                           return_value: true,
                           type: :expect
                         }
                       ],
                       facts: [
                         %Fact{
                           check_id: ^check_id,
                           name: "some_fact",
                           value: "value_on_second_condition"
                         }
                       ],
                       values: [
                         %Value{name: "some_value", value: "value_on_second_condition"}
                       ]
                     }
                   ],
                   check_id: ^check_id,
                   expectation_results: [
                     %ExpectationResult{
                       name: "some_expectation",
                       result: true,
                       type: :expect
                     }
                   ],
                   result: :passing
                 }
               ],
               result: :passing,
               timeout: []
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts, env, engine)
    end

    test "should return a passing result based on the default value when environmental condition does not match",
         %{checks: [%{id: check_id}] = checks, engine: engine} do
      gathered_facts = %{
        check_id => %{
          "agent_1" => [
            %Fact{name: "some_fact", check_id: check_id, value: "a_default_value"}
          ],
          "agent_2" => [
            %Fact{name: "some_fact", check_id: check_id, value: "a_default_value"}
          ]
        }
      }

      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()

      expected_result = %Result{
        execution_id: execution_id,
        group_id: group_id,
        check_results: [
          %CheckResult{
            agents_check_results: [
              %AgentCheckResult{
                agent_id: "agent_1",
                expectation_evaluations: [
                  %ExpectationEvaluation{
                    name: "some_expectation",
                    return_value: true,
                    type: :expect
                  }
                ],
                facts: [
                  %Fact{
                    check_id: check_id,
                    name: "some_fact",
                    value: "a_default_value"
                  }
                ],
                values: [
                  %Value{name: "some_value", value: "a_default_value"}
                ]
              },
              %AgentCheckResult{
                agent_id: "agent_2",
                expectation_evaluations: [
                  %ExpectationEvaluation{
                    name: "some_expectation",
                    return_value: true,
                    type: :expect
                  }
                ],
                facts: [
                  %Fact{
                    check_id: check_id,
                    name: "some_fact",
                    value: "a_default_value"
                  }
                ],
                values: [
                  %Value{name: "some_value", value: "a_default_value"}
                ]
              }
            ],
            check_id: check_id,
            expectation_results: [
              %ExpectationResult{
                name: "some_expectation",
                result: true,
                type: :expect
              }
            ],
            result: :passing
          }
        ],
        result: :passing,
        timeout: []
      }

      assert ^expected_result =
               Evaluation.execute(
                 execution_id,
                 group_id,
                 checks,
                 gathered_facts,
                 %{
                   "some_value" => "unrecognized"
                 },
                 engine
               )

      assert ^expected_result =
               Evaluation.execute(
                 execution_id,
                 group_id,
                 checks,
                 gathered_facts,
                 %{
                   "some_value" => nil
                 },
                 engine
               )

      assert ^expected_result =
               Evaluation.execute(
                 execution_id,
                 group_id,
                 checks,
                 gathered_facts,
                 %{
                   "some_value" => ""
                 },
                 engine
               )

      assert ^expected_result =
               Evaluation.execute(
                 execution_id,
                 group_id,
                 checks,
                 gathered_facts,
                 %{
                   "unrecognized_value" => "some"
                 },
                 engine
               )
    end

    test "should return a critical result when expectation does not match expected evaluated value",
         %{checks: [%{id: check_id}] = checks, engine: engine} do
      env = %{"some_env" => "whoa"}

      gathered_facts = %{
        check_id => %{
          "agent_1" => [
            %Fact{name: "some_fact", check_id: check_id, value: "bad_value"}
          ],
          "agent_2" => [
            %Fact{name: "some_fact", check_id: check_id, value: "value_on_first_condition"}
          ]
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
                           name: "some_expectation",
                           return_value: false,
                           type: :expect
                         }
                       ],
                       facts: [
                         %Fact{
                           check_id: ^check_id,
                           name: "some_fact",
                           value: "bad_value"
                         }
                       ],
                       values: [
                         %Value{name: "some_value", value: "value_on_first_condition"}
                       ]
                     },
                     %AgentCheckResult{
                       agent_id: "agent_2",
                       expectation_evaluations: [
                         %ExpectationEvaluation{
                           name: "some_expectation",
                           return_value: true,
                           type: :expect
                         }
                       ],
                       facts: [
                         %Fact{
                           check_id: ^check_id,
                           name: "some_fact",
                           value: "value_on_first_condition"
                         }
                       ],
                       values: [
                         %Value{name: "some_value", value: "value_on_first_condition"}
                       ]
                     }
                   ],
                   check_id: ^check_id,
                   expectation_results: [
                     %ExpectationResult{
                       name: "some_expectation",
                       result: false,
                       type: :expect
                     }
                   ],
                   result: :critical
                 }
               ],
               result: :critical
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts, env, engine)
    end
  end

  describe "failure message is evaluated" do
    test "should return an evaluated failure message inside the expectation evaluation when the result is false, otherwise a nil field",
         %{engine: engine} do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      fact_value = Enum.random(1..10)
      incorrect_fact_value = Enum.random(11..20)

      [%Catalog.Fact{name: fact_name}] = catalog_facts = build_list(1, :catalog_fact)

      [%Catalog.Expectation{name: expectation_name}] =
        expectations =
        build_list(1, :catalog_expectation,
          type: :expect,
          expression: "facts.#{fact_name} == #{fact_value}",
          failure_message: "failure checking ${facts.#{fact_name}}"
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

      interpolated_failure_message = "failure checking #{incorrect_fact_value}"

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
                           type: :expect,
                           failure_message: ^interpolated_failure_message
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
                           type: :expect,
                           failure_message: nil
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
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts, %{}, engine)
    end

    test "should return a failure message inside the result when having a failing expect_same", %{
      engine: engine
    } do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      fact_value = Enum.random(1..10)
      incorrect_fact_value = Enum.random(11..20)

      [%Catalog.Fact{name: fact_name}] = catalog_facts = build_list(1, :catalog_fact)

      failure_message = "failure checking #{fact_name}"

      [%Catalog.Expectation{name: expectation_name}] =
        expectations =
        build_list(1, :catalog_expectation,
          type: :expect_same,
          expression: "facts.#{fact_name} == #{fact_value}",
          failure_message: failure_message
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
                       type: :expect_same,
                       failure_message: ^failure_message
                     }
                   ],
                   result: :critical
                 }
               ],
               result: :critical
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts, %{}, engine)
    end

    test "should return the default failure message inside the result when having a failing expect_same",
         %{engine: engine} do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()

      fact_name = Faker.Lorem.word()
      fact_value = Faker.Lorem.sentence()
      expectation_name = Faker.Lorem.word()

      another_fact_name = Faker.Code.iban()
      another_fact_value = Faker.Lorem.paragraph()
      another_expectation_name = Faker.Code.iban()

      incorrect_fact_value = Faker.Cat.name()

      [%Catalog.Check{id: check_id}] =
        checks =
        build_list(1, :check,
          severity: :critical,
          facts: [
            build(:catalog_fact, name: fact_name),
            build(:catalog_fact, name: another_fact_name)
          ],
          values: [],
          expectations: [
            build(:catalog_expectation,
              name: expectation_name,
              type: :expect_same,
              expression: "facts.#{fact_name}"
            ),
            build(:catalog_expectation,
              name: another_expectation_name,
              type: :expect_same,
              expression: "facts.#{another_fact_name} == \"#{another_fact_value}\""
            )
          ]
        )

      gathered_facts = %{
        check_id => %{
          "agent_1" => [
            build(:fact, name: fact_name, check_id: check_id, value: fact_value),
            build(:fact, name: another_fact_name, check_id: check_id, value: another_fact_value)
          ],
          "agent_2" => [
            build(:fact,
              name: fact_name,
              check_id: check_id,
              value: incorrect_fact_value
            ),
            build(:fact,
              name: another_fact_name,
              check_id: check_id,
              value: incorrect_fact_value
            )
          ]
        }
      }

      assert %Result{
               execution_id: ^execution_id,
               group_id: ^group_id,
               check_results: [
                 %CheckResult{
                   check_id: ^check_id,
                   expectation_results: [
                     %ExpectationResult{
                       name: ^another_expectation_name,
                       result: false,
                       type: :expect_same,
                       failure_message: "Expectation not met"
                     },
                     %ExpectationResult{
                       name: ^expectation_name,
                       result: false,
                       type: :expect_same,
                       failure_message: "Expectation not met"
                     }
                   ],
                   result: :critical
                 }
               ],
               result: :critical
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts, %{}, engine)
    end

    test "should return a default failure message in case of an erroring interpolation", %{
      engine: engine
    } do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      fact_value = Enum.random(1..10)
      incorrect_fact_value = Enum.random(11..20)

      [%Catalog.Fact{name: fact_name}] = catalog_facts = build_list(1, :catalog_fact)

      [%Catalog.Expectation{name: expectation_name}] =
        expectations =
        build_list(1, :catalog_expectation,
          type: :expect,
          expression: "facts.#{fact_name} == #{fact_value}",
          failure_message: "failure checking ${facts.kekw}"
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
                           type: :expect,
                           failure_message: "Expectation not met"
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
                           type: :expect,
                           failure_message: nil
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
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts, %{}, engine)
    end
  end
end

defmodule Wanda.Executions.EvaluationTest do
  use ExUnit.Case

  import Wanda.Factory

  alias Wanda.Catalog

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
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts, %{})
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
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts, %{})
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
                       result: true,
                       type: :expect
                     }
                   ],
                   result: :critical
                 }
               ],
               result: :critical
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts, %{})
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
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts, %{})
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
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts, %{})
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
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts, %{})
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
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts, %{})
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
                       result: true,
                       type: :expect
                     }
                   ],
                   result: :critical
                 }
               ],
               result: :critical
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts, %{})
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
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts, %{})
    end
  end

  describe "expressions with arrays" do
    test "should return a passing result" do
      [value | _] =
        array = 1..10 |> Enum.random() |> Faker.Util.list(fn _ -> Faker.StarWars.character() end)

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
             } = Evaluation.execute(UUID.uuid4(), UUID.uuid4(), checks, gathered_facts, %{})
    end
  end

  describe "expression with maps" do
    test "should return a passing result" do
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
             } = Evaluation.execute(UUID.uuid4(), UUID.uuid4(), checks, gathered_facts, %{})
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
         context do
      checks = [%{id: check_id}] = context[:checks]

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
               Evaluation.execute(execution_id, group_id, checks, gathered_facts, %{
                 "some_env" => "whoa"
               })

      assert ^expected_result =
               Evaluation.execute(execution_id, group_id, checks, gathered_facts, %{
                 "some_env" => "yeah"
               })
    end

    test "should return a passing result based on the proper environmental conditions matching",
         context do
      checks = [%{id: check_id}] = context[:checks]

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
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts, env)
    end

    test "should return a passing result based on the default value when environmental condition does not match",
         context do
      checks = [%{id: check_id}] = context[:checks]

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
               Evaluation.execute(execution_id, group_id, checks, gathered_facts, %{
                 "some_value" => "unrecognized"
               })

      assert ^expected_result =
               Evaluation.execute(execution_id, group_id, checks, gathered_facts, %{
                 "some_value" => nil
               })

      assert ^expected_result =
               Evaluation.execute(execution_id, group_id, checks, gathered_facts, %{
                 "some_value" => ""
               })

      assert ^expected_result =
               Evaluation.execute(execution_id, group_id, checks, gathered_facts, %{
                 "unrecognized_value" => "some"
               })
    end

    test "should return a critical result when expectation does not match expected evaluated value",
         context do
      checks = [%{id: check_id}] = context[:checks]
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
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts, env)
    end
  end
end

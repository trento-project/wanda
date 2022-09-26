defmodule Wanda.Execution.EvaluationTest do
  use ExUnit.Case

  alias Wanda.Catalog

  alias Wanda.Execution.{
    AgentCheckError,
    AgentCheckResult,
    CheckResult,
    Evaluation,
    ExpectationEvaluation,
    ExpectationEvaluationError,
    ExpectationResult,
    Fact,
    FactError,
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
      checks = [Catalog.get_check("expect_check")]

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
                       facts: [
                         %Fact{
                           check_id: "expect_check",
                           name: "corosync_token_timeout",
                           value: 30_000
                         }
                       ]
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
                       facts: [
                         %Fact{
                           check_id: "expect_check",
                           name: "corosync_token_timeout",
                           value: 30_000
                         }
                       ]
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
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts)
    end

    test "should return a critical result when not all the agents fullfill the expectations with an expect condition" do
      gathered_facts = %{
        "expect_check" => %{
          "agent_1" => %{
            "corosync_token_timeout" => 10_000
          },
          "agent_2" => %{
            "corosync_token_timeout" => 30_000
          }
        }
      }

      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      checks = [Catalog.get_check("expect_check")]

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
                           return_value: false,
                           type: :expect
                         }
                       ],
                       facts: [
                         %Fact{
                           check_id: "expect_check",
                           name: "corosync_token_timeout",
                           value: 10_000
                         }
                       ]
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
                       facts: [
                         %Fact{
                           check_id: "expect_check",
                           name: "corosync_token_timeout",
                           value: 30_000
                         }
                       ]
                     }
                   ],
                   check_id: "expect_check",
                   expectation_results: [
                     %ExpectationResult{
                       name: "timeout",
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
      gathered_facts = %{
        "expect_check" => %{
          "agent_1" => %{
            "corosync_token_timeout" => 10_000
          },
          "agent_2" => %{
            "corosync_token_timeout" => %{
              type: "some-error",
              message: "some message"
            }
          }
        }
      }

      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      checks = [Catalog.get_check("expect_check")]

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
                           return_value: false,
                           type: :expect
                         }
                       ],
                       facts: [
                         %Fact{
                           check_id: "expect_check",
                           name: "corosync_token_timeout",
                           value: 10_000
                         }
                       ]
                     },
                     %AgentCheckResult{
                       agent_id: "agent_2",
                       expectation_evaluations: [
                         %ExpectationEvaluation{
                           name: "timeout",
                           return_value: false,
                           type: :expect
                         }
                       ],
                       facts: [
                         %FactError{
                           check_id: "expect_check",
                           name: "corosync_token_timeout",
                           type: "some-error",
                           message: "some message"
                         }
                       ]
                     }
                   ],
                   check_id: "expect_check",
                   expectation_results: [
                     %ExpectationResult{
                       name: "timeout",
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
      checks = [Catalog.get_check("expect_same_check")]

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
                       facts: [
                         %Fact{
                           check_id: "expect_same_check",
                           name: "corosync_token_timeout",
                           value: 30_000
                         }
                       ]
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
                       facts: [
                         %Fact{
                           check_id: "expect_same_check",
                           name: "corosync_token_timeout",
                           value: 30_000
                         }
                       ]
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
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts)
    end

    test "should return a passing result when not all the agents fullfill the expectations with an expect_same condition" do
      gathered_facts = %{
        "expect_same_check" => %{
          "agent_1" => %{
            "corosync_token_timeout" => "abc"
          },
          "agent_2" => %{
            "corosync_token_timeout" => 30_000
          }
        }
      }

      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      checks = [Catalog.get_check("expect_same_check")]

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
                           return_value: "abc",
                           type: :expect_same
                         }
                       ],
                       facts: [
                         %Fact{
                           check_id: "expect_same_check",
                           name: "corosync_token_timeout",
                           value: "abc"
                         }
                       ]
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
                       facts: [
                         %Fact{
                           check_id: "expect_same_check",
                           name: "corosync_token_timeout",
                           value: 30_000
                         }
                       ]
                     }
                   ],
                   check_id: "expect_same_check",
                   expectation_results: [
                     %ExpectationResult{
                       name: "timeout",
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
      gathered_facts = %{
        "with_fact_missing_check" => %{
          "agent_1" => %{
            "corosync_token_timeout" => 30_000
          },
          "agent_2" => %{}
        }
      }

      checks = [Catalog.get_check("with_fact_missing_check")]

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
                       facts: []
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
             } = Evaluation.execute(UUID.uuid4(), UUID.uuid4(), checks, gathered_facts)
    end

    test "should return a critical result if an illegal expression was specified in a check expectation" do
      gathered_facts = %{
        "with_illegal_expression_check" => %{
          "agent_1" => %{
            "jedi" => Faker.StarWars.character()
          },
          "agent_2" => %{
            "jedi" => Faker.StarWars.character()
          }
        }
      }

      checks = [Catalog.get_check("with_illegal_expression_check")]

      assert %Result{
               result: :critical,
               check_results: [
                 %CheckResult{
                   result: :critical,
                   check_id: "with_illegal_expression_check",
                   agents_check_results: [
                     %AgentCheckResult{
                       agent_id: "agent_1",
                       expectation_evaluations: [
                         %ExpectationEvaluationError{
                           name: "illegal_expression",
                           type: :illegal_expression_error
                         }
                       ]
                     },
                     %AgentCheckResult{
                       agent_id: "agent_2",
                       expectation_evaluations: [
                         %ExpectationEvaluationError{
                           name: "illegal_expression",
                           type: :illegal_expression_error
                         }
                       ]
                     }
                   ],
                   expectation_results: [
                     %ExpectationResult{
                       name: "illegal_expression",
                       result: false,
                       type: :expect
                     }
                   ]
                 }
               ]
             } = Evaluation.execute(UUID.uuid4(), UUID.uuid4(), checks, gathered_facts)
    end

    test "should return a critical result if an agent times out" do
      gathered_facts = %{
        "expect_check" => %{
          "agent_1" => %{
            "corosync_token_timeout" => 30_000
          },
          "agent_2" => %{
            "corosync_token_timeout" => 30_000
          },
          "agent_3" => :timeout
        }
      }

      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()
      checks = [Catalog.get_check("expect_check")]

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
                       facts: [
                         %Fact{
                           check_id: "expect_check",
                           name: "corosync_token_timeout",
                           value: 30_000
                         }
                       ]
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
                       facts: [
                         %Fact{
                           check_id: "expect_check",
                           name: "corosync_token_timeout",
                           value: 30_000
                         }
                       ]
                     },
                     %AgentCheckError{
                       agent_id: "agent_3",
                       message: "Agent timed out during the execution",
                       type: :timeout
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
                   result: :critical
                 }
               ],
               result: :critical
             } = Evaluation.execute(execution_id, group_id, checks, gathered_facts)
    end
  end
end

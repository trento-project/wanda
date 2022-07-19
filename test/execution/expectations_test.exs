defmodule Wanda.Execution.ExpectationsTest do
  use ExUnit.Case

  alias Wanda.Execution.{
    CheckResult,
    ExpectationResult,
    Expectations,
    Result
  }

  test "should eval the expectations and return a list of results" do
    gathered_facts = %{
      "agent_1" => %{
        "happy" => %{
          "corosync_token_timeout" => 30_000,
          "http_port_open" => true
        }
      },
      "agent_2" => %{
        "happy" => %{
          "corosync_token_timeout" => 30_001,
          "http_port_open" => false
        }
      }
    }

    assert [
             %Result{
               agent_id: "agent_1",
               checks_results: [
                 %CheckResult{
                   check_id: "happy",
                   expectations_results: [
                     %ExpectationResult{name: "timeout", result: true},
                     %ExpectationResult{
                       name: "http_port_open",
                       result: true
                     }
                   ],
                   facts: %{"corosync_token_timeout" => 30_000, "http_port_open" => true},
                   result: :passing
                 }
               ]
             },
             %Result{
               agent_id: "agent_2",
               checks_results: [
                 %CheckResult{
                   check_id: "happy",
                   expectations_results: [
                     %ExpectationResult{name: "timeout", result: false},
                     %ExpectationResult{
                       name: "http_port_open",
                       result: false
                     }
                   ],
                   facts: %{"corosync_token_timeout" => 30_001, "http_port_open" => false},
                   result: :critical
                 }
               ]
             }
           ] == Expectations.eval(gathered_facts)
  end

  test "should return errors when the expressions are illegal" do
    gathered_facts = %{
      "agent_1" => %{
        "with_illegal_expression" => %{
          "corosync_token_timeout" => 30_000
        }
      }
    }

    assert [
             %Result{
               checks_results: [
                 %CheckResult{
                   result: :critical,
                   check_id: "with_illegal_expression",
                   expectations_results: [
                     %ExpectationResult{
                       name: "illegal_expression",
                       result: :illegal_expression_error
                     }
                   ]
                 }
               ]
             }
           ] = Expectations.eval(gathered_facts)
  end

  test "should return errors when the facts are missing" do
    gathered_facts = %{
      "agent_1" => %{
        "with_fact_missing" => %{}
      }
    }

    assert [
             %Result{
               checks_results: [
                 %CheckResult{
                   result: :critical,
                   check_id: "with_fact_missing",
                   expectations_results: [
                     %ExpectationResult{
                       name: "fact_missing",
                       result: :fact_missing_error
                     }
                   ]
                 }
               ]
             }
           ] = Expectations.eval(gathered_facts)
  end
end

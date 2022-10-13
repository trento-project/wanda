# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Wanda.Repo.insert!(%Wanda.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

execution_id = "00000000-0000-0000-0000-000000000001"
group_id = "00000000-0000-0000-0000-000000000002"

Wanda.Results.create_execution_result!(%Wanda.Execution.Result{
  execution_id: execution_id,
  group_id: group_id,
  check_results: [
    %Wanda.Execution.CheckResult{
      agents_check_results: [
        %Wanda.Execution.AgentCheckResult{
          agent_id: "agent_1",
          expectation_evaluations: [
            %Wanda.Execution.ExpectationEvaluation{
              name: "timeout",
              return_value: true,
              type: :expect
            }
          ],
          facts: [
            %Wanda.Execution.Fact{
              check_id: "expect_check",
              name: "corosync_token_timeout",
              value: 30_000
            }
          ]
        },
        %Wanda.Execution.AgentCheckResult{
          agent_id: "agent_2",
          expectation_evaluations: [
            %Wanda.Execution.ExpectationEvaluation{
              name: "timeout",
              return_value: true,
              type: :expect
            }
          ],
          facts: [
            %Wanda.Execution.Fact{
              check_id: "expect_check",
              name: "corosync_token_timeout",
              value: 30_000
            }
          ]
        }
      ],
      check_id: "expect_check",
      expectation_results: [
        %Wanda.Execution.ExpectationResult{
          name: "timeout",
          result: true,
          type: :expect
        }
      ],
      result: :passing
    }
  ],
  result: :passing
})

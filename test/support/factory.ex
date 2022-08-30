defmodule Wanda.Factory do
  @moduledoc false

  use ExMachina

  alias Wanda.Execution.{
    AgentCheckResult,
    CheckResult,
    ExpectationEvaluation,
    ExpectationResult,
    Fact,
    FactsRequest,
    Result,
    Target
  }

  def target_factory(attrs) do
    %Target{
      agent_id: Map.get(attrs, :agent_id, UUID.uuid4()),
      checks: Map.get(attrs, :checks, Enum.map(1..10, fn _ -> UUID.uuid4() end))
    }
  end

  def fact_factory(attrs) do
    %Fact{
      check_id: Map.get(attrs, :name, UUID.uuid4()),
      name: Map.get(attrs, :name, Faker.StarWars.character()),
      value: Map.get(attrs, :value, Faker.StarWars.planet())
    }
  end

  def execution_result_factory(attrs) do
    %Result{
      execution_id: Map.get(attrs, :execution_id, UUID.uuid4()),
      group_id: Map.get(attrs, :group_id, UUID.uuid4()),
      check_results:
        Map.get(attrs, :check_results, [
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
        ]),
      result: :passing
    }
  end

  def facts_request_factory(attrs) do
    agent_id = UUID.uuid4()

    %FactsRequest{
      execution_id: Map.get(attrs, :execution_id, UUID.uuid4()),
      group_id: Map.get(attrs, :group_id, UUID.uuid4()),
      targets: Map.get(attrs, :targets, [agent_id]),
      facts:
        Map.get(attrs, :facts, [
          %Wanda.Execution.AgentFacts{
            agent_id: agent_id,
            facts: [
              %Wanda.Catalog.Fact{
                check_id: "CHK01",
                name: "some_fact_name",
                gatherer: "some_gatherer",
                argument: "some_argument"
              },
              %Wanda.Catalog.Fact{
                check_id: "CHK02",
                name: "another_fact_name",
                gatherer: "another_gatherer",
                argument: "another_argument"
              }
            ]
          }
        ])
    }
  end
end

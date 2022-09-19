defmodule Wanda.Factory do
  @moduledoc false

  use ExMachina

  alias Wanda.Catalog

  alias Wanda.Execution.{
    AgentCheckResult,
    CheckResult,
    ExpectationEvaluation,
    ExpectationEvaluationError,
    ExpectationResult,
    Fact,
    Result,
    Target
  }

  def check_factory(attrs) do
    %Catalog.Check{
      id: Map.get(attrs, :id, UUID.uuid4()),
      name: Map.get(attrs, :id, Faker.StarWars.character()),
      facts: Map.get(attrs, :facts, build_list(10, :catalog_fact)),
      expectations: Map.get(attrs, :expectations, build_list(10, :catalog_expectation))
    }
  end

  def catalog_fact_factory(attrs) do
    %Catalog.Fact{
      name: Map.get(attrs, :name, Faker.StarWars.character()),
      gatherer: Map.get(attrs, :gatherer, Faker.StarWars.character()),
      argument: Map.get(attrs, :argument, Faker.StarWars.quote())
    }
  end

  def catalog_expectation_factory(attrs) do
    %Catalog.Fact{
      name: Map.get(attrs, :name, Faker.StarWars.character()),
      gatherer: Map.get(attrs, :gatherer, Faker.StarWars.character()),
      argument: Map.get(attrs, :argument, Faker.StarWars.quote())
    }
  end

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
      check_results: [
        %CheckResult{
          agents_check_results: [
            %AgentCheckResult{
              agent_id: "agent_1",
              facts: [
                %Fact{
                  name: "corosync_timeout",
                  value: 1000
                }
              ],
              expectation_evaluations: [
                %ExpectationEvaluation{
                  name: "corosync_timeout",
                  return_value: true,
                  type: :expect
                }
              ]
            },
            %AgentCheckResult{
              agent_id: "agent_2",
              facts: [
                %Fact{
                  name: "corosync_timeout",
                  value: 1000
                }
              ],
              expectation_evaluations: [
                %ExpectationEvaluation{
                  name: "corosync_timeout",
                  return_value: true,
                  type: :expect
                },
                %ExpectationEvaluationError{
                  name: "corosync_timeout",
                  message: "error_message",
                  type: :fact_missing_error
                }
              ]
            }
          ],
          check_id: "expect_check",
          expectation_results: [
            %ExpectationResult{
              name: "corosync_timeout",
              result: true,
              type: :expect
            }
          ],
          result: :passing
        }
      ],
      result: :passing
    }
  end
end

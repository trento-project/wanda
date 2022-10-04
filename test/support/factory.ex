defmodule Wanda.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Wanda.Repo

  alias Wanda.Catalog

  alias Wanda.Execution.{
    AgentCheckResult,
    CheckResult,
    ExpectationEvaluation,
    ExpectationEvaluationError,
    ExpectationResult,
    Fact,
    FactError,
    Result,
    Target
  }

  alias Wanda.Results.ExecutionResult

  def map_factory(attrs) do
    count = Map.get(attrs, :count, 5)

    Enum.reduce(0..count, %{}, fn _, acc ->
      Map.put(acc, Faker.Pokemon.name(), Faker.Pokemon.name())
    end)
  end

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
      check_id: Map.get(attrs, :check_id, UUID.uuid4()),
      name: Map.get(attrs, :name, Faker.StarWars.character()),
      value: Map.get(attrs, :value, Faker.StarWars.planet())
    }
  end

  def fact_error_factory(attrs) do
    %FactError{
      check_id: Map.get(attrs, :check_id, UUID.uuid4()),
      name: Map.get(attrs, :name, Faker.StarWars.character()),
      type: Map.get(attrs, :type, Faker.StarWars.planet()),
      message: Map.get(attrs, :message, Faker.StarWars.quote())
    }
  end

  def result_factory(attrs) do
    %Result{
      execution_id: Map.get(attrs, :execution_id, UUID.uuid4()),
      group_id: Map.get(attrs, :group_id, UUID.uuid4()),
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
              ]
            },
            %AgentCheckResult{
              agent_id: "agent_2",
              expectation_evaluations: [
                %ExpectationEvaluation{
                  name: "timeout",
                  return_value: true,
                  type: :expect
                },
                %ExpectationEvaluationError{
                  name: "timeout",
                  message: Faker.StarWars.quote(),
                  type: :fact_missing_error
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
      result: Map.get(attrs, :result, Enum.random([:passing, :warning, :critical]))
    }
  end

  def execution_result_factory(attrs) do
    execution_id = Map.get(attrs, :execution_id, Faker.UUID.v4())
    group_id = Map.get(attrs, :group_id, Faker.UUID.v4())

    %ExecutionResult{
      execution_id: execution_id,
      group_id: group_id,
      payload: build(:result, execution_id: execution_id, group_id: group_id)
    }
  end
end

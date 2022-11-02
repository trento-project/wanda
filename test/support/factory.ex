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

  def check_factory(attrs) do
    %Catalog.Check{
      id: Map.get(attrs, :id, UUID.uuid4()),
      name: Map.get(attrs, :name, Faker.StarWars.character()),
      severity: Map.get(attrs, :severity, Enum.random([:critical, :warning, :passing])),
      facts: Map.get(attrs, :facts, build_list(10, :catalog_fact)),
      values: Map.get(attrs, :values, build_list(10, :catalog_value)),
      expectations: Map.get(attrs, :expectations, build_list(10, :catalog_expectation))
    }
  end

  def catalog_fact_factory(attrs) do
    %Catalog.Fact{
      name: Map.get(attrs, :name, Faker.Cat.name()),
      gatherer: Map.get(attrs, :gatherer, Faker.StarWars.character()),
      argument: Map.get(attrs, :argument, Faker.StarWars.quote())
    }
  end

  def catalog_value_factory(attrs) do
    %Catalog.Value{
      name: Map.get(attrs, :name, Faker.StarWars.character()),
      default: Map.get(attrs, :default, Faker.StarWars.character()),
      conditions: Map.get(attrs, :conditions, build_list(10, :catalog_condition))
    }
  end

  def catalog_condition_factory(attrs) do
    %Catalog.Condition{
      value: Map.get(attrs, :value, Faker.StarWars.character()),
      expression: Map.get(attrs, :expression, Faker.StarWars.quote())
    }
  end

  def catalog_expectation_factory(attrs) do
    %Catalog.Expectation{
      name: Map.get(attrs, :name, Faker.StarWars.character()),
      type: Map.get(attrs, :type, Enum.random([:expect, :expect_same])),
      expression: Map.get(attrs, :expression, Faker.StarWars.quote())
    }
  end

  def target_factory(attrs) do
    %Target{
      agent_id: Map.get(attrs, :agent_id, UUID.uuid4()),
      checks:
        Map.get(
          attrs,
          :checks,
          1..10 |> Enum.map(fn _ -> Faker.StarWars.planet() end) |> Enum.uniq()
        )
    }
  end

  def env_factory(attrs) do
    count = Map.get(attrs, :count, 5)

    Enum.reduce(0..count, %{}, fn _, acc ->
      Map.put(acc, Faker.Pokemon.name(), random_env_value())
    end)
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
              agent_id: UUID.uuid4(),
              expectation_evaluations: [
                %ExpectationEvaluation{
                  name: "timeout",
                  return_value: true,
                  type: :expect
                }
              ]
            },
            %AgentCheckResult{
              agent_id: UUID.uuid4(),
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

  def execution_result_factory do
    %ExecutionResult{
      execution_id: Faker.UUID.v4(),
      group_id: Faker.UUID.v4(),
      status: :running,
      targets: [],
      started_at: DateTime.utc_now()
    }
  end

  def with_completed_status(
        %ExecutionResult{execution_id: execution_id, group_id: group_id} = execution_result
      ) do
    %ExecutionResult{
      execution_result
      | status: :completed,
        payload: build(:result, execution_id: execution_id, group_id: group_id),
        completed_at: DateTime.utc_now()
    }
  end

  defp random_env_value do
    Faker.Util.pick([
      Faker.Pokemon.name(),
      Enum.random(1..10),
      Enum.random([false, true])
    ])
  end
end

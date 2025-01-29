defmodule Wanda.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Wanda.Repo

  alias Wanda.Catalog
  alias Wanda.Catalog.CheckCustomization

  alias Wanda.Executions.{
    AgentCheckError,
    AgentCheckResult,
    CheckResult,
    Execution,
    ExpectationEvaluation,
    ExpectationEvaluationError,
    ExpectationResult,
    Fact,
    FactError,
    Result,
    Target
  }

  alias Wanda.Operations.{
    AgentReport,
    Operation,
    OperationTarget,
    StepReport
  }

  alias Wanda.Operations.Catalog.Operation, as: CatalogOperation
  alias Wanda.Operations.Catalog.Step
  alias Wanda.Users.User

  require Wanda.Catalog.Enums.ExpectType, as: ExpectType
  require Wanda.Catalog.Enums.Severity, as: Severity
  require Wanda.Executions.Enums.Result, as: ExecutionResult
  require Wanda.Executions.Enums.Status, as: ExecutionStatus
  require Wanda.Operations.Enums.Result, as: OpeartionResult
  require Wanda.Operations.Enums.Status, as: OpeartionStatus

  def check_factory do
    %Catalog.Check{
      id: UUID.uuid4(),
      name: Faker.StarWars.character(),
      group: Faker.Company.name(),
      description: Faker.Lorem.sentence(),
      remediation: Faker.Lorem.sentence(),
      metadata: %{
        target_type: Enum.random(["cluster", "host"]),
        cluster_type: Enum.random(["ascs_ers", "hana_scale_up"]),
        provider:
          Enum.take_random(["azure", "nutanix", "kvm", "vmware, gcp, aws"], Enum.random(1..6))
      },
      severity: Enum.random(Severity.values()),
      facts: build_list(10, :catalog_fact),
      values: build_list(10, :catalog_value),
      expectations: build_list(10, :catalog_expectation),
      when: Faker.Lorem.sentence(),
      customizable: Enum.random([false, true])
    }
  end

  def catalog_fact_factory do
    %Catalog.Fact{
      name: Faker.Cat.name(),
      gatherer: Faker.StarWars.character(),
      argument: Faker.StarWars.quote()
    }
  end

  def catalog_value_factory do
    %Catalog.Value{
      name: Faker.StarWars.character(),
      default: Faker.StarWars.character(),
      conditions: build_list(10, :catalog_condition),
      customizable: Enum.random([false, true])
    }
  end

  def catalog_condition_factory do
    %Catalog.Condition{
      value: Faker.StarWars.character(),
      expression: Faker.StarWars.quote()
    }
  end

  def catalog_expectation_factory do
    %Catalog.Expectation{
      name: Faker.StarWars.character(),
      type: Enum.random(ExpectType.values()),
      expression: Faker.StarWars.quote(),
      failure_message: Faker.Lorem.sentence(),
      warning_message: Faker.Lorem.sentence()
    }
  end

  def target_factory do
    %Target{
      agent_id: UUID.uuid4(),
      checks: random_checks()
    }
  end

  def env_factory(attrs) do
    count = Map.get(attrs, :count, 5)

    Enum.into(0..count, %{}, fn _ ->
      {Faker.Pokemon.name(), random_env_value()}
    end)
  end

  def fact_factory do
    %Fact{
      check_id: UUID.uuid4(),
      name: Faker.StarWars.character(),
      value: Faker.StarWars.planet()
    }
  end

  def fact_error_factory do
    %FactError{
      check_id: UUID.uuid4(),
      name: Faker.StarWars.character(),
      type: Faker.StarWars.planet(),
      message: Faker.StarWars.quote()
    }
  end

  def execution_factory do
    %Execution{
      execution_id: Faker.UUID.v4(),
      group_id: Faker.UUID.v4(),
      status: ExecutionStatus.running(),
      targets: 1..5 |> Enum.random() |> build_list(:execution_target),
      started_at: DateTime.utc_now()
    }
  end

  def execution_target_factory do
    %Execution.Target{
      agent_id: Faker.UUID.v4(),
      checks: random_checks()
    }
  end

  def result_factory do
    %Result{
      execution_id: UUID.uuid4(),
      group_id: UUID.uuid4(),
      check_results: build_list(5, :check_result),
      result: ExecutionResult.passing()
    }
  end

  def check_result_factory do
    %CheckResult{
      agents_check_results: build_list(5, :agent_check_result),
      check_id: UUID.uuid4(),
      expectation_results: build_list(5, :expectation_result),
      result: ExecutionResult.passing()
    }
  end

  def agent_check_result_factory do
    %AgentCheckResult{
      agent_id: UUID.uuid4(),
      facts: build_list(2, :fact),
      expectation_evaluations: build_list(2, :expectation_evaluation)
    }
  end

  def agent_check_error_factory do
    %AgentCheckError{
      agent_id: UUID.uuid4(),
      facts: build_list(2, :fact_error),
      type: :fact_gathering_error,
      message: Faker.StarWars.quote()
    }
  end

  def expectation_evaluation_factory do
    %ExpectationEvaluation{
      name: sequence(:name, &"expectation_#{&1}"),
      return_value: true,
      type: ExpectType.expect()
    }
  end

  def expectation_evaluation_error_factory do
    %ExpectationEvaluationError{
      name: sequence(:name, &"expectation_#{&1}"),
      type: :property_not_found,
      message: Faker.StarWars.quote()
    }
  end

  def expectation_result_factory do
    %ExpectationResult{
      name: sequence(:name, &"expectation_#{&1}"),
      result: true,
      type: ExpectType.expect()
    }
  end

  def check_results_from_targets_factory(attrs) do
    targets = Map.get(attrs, :targets, [])
    result = Map.get(attrs, :result, ExecutionResult.passing())
    failure_message = Map.get(attrs, :failure_message)

    targets
    |> Enum.flat_map(& &1.checks)
    |> Enum.uniq()
    |> Enum.map(fn check_id ->
      check_targets = Enum.filter(targets, &(check_id in &1.checks))
      check_result_from_target(check_id, check_targets, result, failure_message)
    end)
  end

  def catalog_operation_factory do
    %CatalogOperation{
      id: UUID.uuid4(),
      name: Faker.StarWars.character(),
      required_args: [],
      steps: build_list(2, :operation_step)
    }
  end

  def operation_step_factory do
    %Step{
      operator: Faker.StarWars.planet(),
      predicate: "*",
      timeout: 10_000
    }
  end

  def operation_factory do
    targets =
      1..5
      |> Enum.random()
      |> build_list(:operation_target)
      |> Enum.map(fn %{agent_id: id, arguments: args} ->
        %Operation.Target{agent_id: id, arguments: args}
      end)

    %Operation{
      operation_id: UUID.uuid4(),
      group_id: UUID.uuid4(),
      result: OpeartionResult.not_executed(),
      status: OpeartionStatus.running(),
      targets: targets,
      agent_reports: [],
      started_at: DateTime.utc_now()
    }
  end

  def operation_target_factory do
    %OperationTarget{
      agent_id: UUID.uuid4(),
      arguments: %{}
    }
  end

  def step_report_factory do
    %StepReport{
      step_number: Enum.random(1..10),
      agents: build_list(2, :agent_report)
    }
  end

  def agent_report_factory do
    %AgentReport{
      agent_id: UUID.uuid4(),
      result: OpeartionResult.updated()
    }
  end

  def user_factory do
    %User{
      id: UUID.uuid4(),
      abilities: build_list(5, :ability)
    }
  end

  def ability_factory do
    %{
      name: Faker.Pokemon.name(),
      resource: Faker.Industry.industry()
    }
  end

  def custom_value_factory do
    %{
      name: Faker.UUID.v4(),
      value: Faker.Pokemon.name()
    }
  end

  def check_customization_factory do
    %CheckCustomization{
      check_id: Faker.UUID.v4(),
      group_id: Faker.UUID.v4(),
      custom_values: build_list(5, :custom_value)
    }
  end

  defp random_env_value do
    Faker.Util.pick([
      Faker.Pokemon.name(),
      Enum.random(1..10),
      Enum.random([false, true])
    ])
  end

  defp random_checks do
    1..10
    |> Enum.map(fn _ -> UUID.uuid4() end)
    |> Enum.take_random(Enum.random(1..5))
  end

  defp check_result_from_target(check_id, check_targets, result, failure_message) do
    expectations_evaluations_expect =
      1..5
      |> Enum.random()
      |> build_list(:expectation_evaluation, return_value: result == ExecutionResult.passing())
      |> Enum.map(fn
        %{return_value: true} = expectation_evaluation ->
          expectation_evaluation

        %{return_value: false} = expectation_evaluation ->
          %ExpectationEvaluation{expectation_evaluation | failure_message: failure_message}
      end)

    expectations_evaluations_expect_same =
      Enum.map(1..Enum.random(1..5), fn _ ->
        build(:expectation_evaluation,
          type: ExpectType.expect_same(),
          return_value:
            if result == ExecutionResult.passing() do
              "same_value"
            else
              Faker.StarWars.quote()
            end
        )
      end)

    expectation_evaluations =
      Enum.shuffle(expectations_evaluations_expect ++ expectations_evaluations_expect_same)

    expectation_results =
      expectation_evaluations
      |> Enum.map(
        &build(:expectation_result,
          name: &1.name,
          type: &1.type,
          result: result == ExecutionResult.passing()
        )
      )
      |> Enum.map(fn
        %ExpectationResult{result: false, type: ExpectType.expect_same()} = expectation_result ->
          %ExpectationResult{expectation_result | failure_message: failure_message}

        expectation_result ->
          expectation_result
      end)

    build(:check_result,
      check_id: check_id,
      agents_check_results:
        Enum.map(check_targets, fn target ->
          build(:agent_check_result,
            agent_id: target.agent_id,
            expectation_evaluations: expectation_evaluations
          )
        end),
      expectation_results: expectation_results,
      result: result
    )
  end
end

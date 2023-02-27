defmodule Wanda.Executions.FakeServer do
  @moduledoc """
  Execution server implementation that does not actually execute anything and just
  returns (fake) random results.
  """
  @behaviour Wanda.Executions.ServerBehaviour

  import Wanda.Factory

  alias Wanda.Executions.Result

  alias Wanda.{
    Catalog,
    Executions,
    Messaging
  }

  @impl true
  def start_execution(execution_id, group_id, targets, env, _config \\ []) do
    checks =
      targets
      |> Executions.Target.get_checks_from_targets()
      |> Catalog.get_checks(env)

    checks_ids = Enum.map(checks, & &1.id)

    targets =
      Enum.map(targets, fn %{checks: target_checks} = target ->
        %Executions.Target{target | checks: target_checks -- target_checks -- checks_ids}
      end)

    create_fake_execution(execution_id, group_id, targets)
    Process.sleep(2_000)
    complete_fake_execution(execution_id, group_id, targets)

    :ok
  end

  @impl true
  def receive_facts(_execution_id, _group_id, _agent_id, _facts) do
    :ok
  end

  defp create_fake_execution(execution_id, group_id, targets) do
    insert(:execution,
      status: :running,
      execution_id: execution_id,
      group_id: group_id,
      targets: Enum.map(targets, &Map.from_struct/1)
    )

    Executions.create_execution!(execution_id, group_id, targets)
    execution_started = Messaging.Mapper.to_execution_started(execution_id, group_id, targets)
    :ok = Messaging.publish("results", execution_started)
  end

  defp complete_fake_execution(execution_id, group_id, targets) do
    result = Enum.random([:passing, :warning, :critical])
    check_results = check_results_from_targets(targets, result)

    build_result =
      build(:result,
        check_results: check_results,
        execution_id: execution_id,
        group_id: group_id
      )

    Executions.complete_execution!(
      execution_id,
      Map.put(build_result, :result, get_result(build_result))
    )

    execution_completed = Messaging.Mapper.to_execution_completed(build_result)
    :ok = Messaging.publish("results", execution_completed)
  end

  defp get_result(%Result{check_results: check_results}) do
    check_results
    |> Enum.map(& &1.result)
    |> Enum.map(&{&1, result_weight(&1)})
    |> Enum.max_by(fn {_, weight} -> weight end)
    |> elem(0)
  end

  defp result_weight(:critical), do: 2
  defp result_weight(:warning), do: 1
  defp result_weight(:passing), do: 0

  defp check_results_from_targets(targets, result) do
    targets
    |> Enum.flat_map(& &1.checks)
    |> Enum.uniq()
    |> Enum.map(fn check_id ->
      check_targets = Enum.filter(targets, &(check_id in &1.checks))
      check_result_from_target(check_id, check_targets, result)
    end)
  end

  defp expectation_evaluations_from_check(check, result) do
    Enum.map(check.expectations, fn expectation ->
      case expectation.type do
        :expect ->
          build(:expectation_evaluation,
            type: :expect,
            name: expectation.name,
            return_value: result == :passing
          )

        :expect_same ->
          build(:expectation_evaluation,
            type: :expect_same,
            name: expectation.name,
            return_value:
              if result == :passing do
                "same_value"
              else
                Faker.StarWars.quote()
              end
          )
      end
    end)
  end

  defp check_result_from_target(check_id, check_targets, result) do
    {_, check} = Catalog.get_check(check_id)
    expectation_evaluations = expectation_evaluations_from_check(check, result)

    expectation_results =
      Enum.map(
        expectation_evaluations,
        &build(:expectation_result, name: &1.name, type: &1.type, result: result == :passing)
      )

    build(:check_result,
      check_id: check_id,
      agents_check_results:
        Enum.map(check_targets, fn target ->
          build(:agent_check_result,
            agent_id: target.agent_id,
            facts:
              Enum.map(check.facts, fn fact ->
                build(:fact, check_id: check_id, name: fact.name)
              end),
            expectation_evaluations: expectation_evaluations,
            values: check.values
          )
        end),
      expectation_results: expectation_results,
      result: result
    )
  end
end

defmodule Wanda.Executions.FakeEvaluation do
  @moduledoc """
  Fake evaluation functional core.
  """

  import Wanda.Factory

  @spec complete_fake_execution(
          String.t(),
          String.t(),
          [Wanda.Executions.Target.t()],
          [Wanda.Catalog.Check.t()]
        ) :: Wanda.Executions.Result.t()
  def complete_fake_execution(execution_id, group_id, targets, checks) do
    result = Enum.random([:passing, :warning, :critical])
    check_results = build_check_results_from_targets(targets, result, checks)

    build(:result,
      check_results: check_results,
      execution_id: execution_id,
      group_id: group_id,
      result: result
    )
  end

  defp build_check_results_from_targets(targets, result, checks) do
    targets
    |> Enum.flat_map(& &1.checks)
    |> Enum.uniq()
    |> Enum.map(fn check_id ->
      check_targets = Enum.filter(targets, &(check_id in &1.checks))
      build_check_result_from_target(check_id, check_targets, result, checks)
    end)
  end

  defp build_check_result_from_target(check_id, check_targets, result, checks) do
    check = Enum.find(checks, &(&1.id == check_id))

    build(:check_result,
      check_id: check_id,
      agents_check_results:
        Enum.map(check_targets, fn %{agent_id: agent_id} ->
          build(:agent_check_result,
            agent_id: agent_id,
            facts:
              Enum.map(check.facts, fn %{name: name} ->
                build(:fact, check_id: check_id, name: name)
              end),
            expectation_evaluations: expectation_evaluations_from_check(check, result),
            values:
              Enum.map(check.values, fn %{name: name, default: value} ->
                %{name: name, value: value}
              end)
          )
        end),
      expectation_results:
        Enum.map(
          expectation_evaluations_from_check(check, result),
          &build(:expectation_result, name: &1.name, type: &1.type, result: result == :passing)
        ),
      result: result
    )
  end

  defp expectation_evaluations_from_check(check, result) do
    Enum.map(check.expectations, fn %{type: type, name: name} ->
      case type do
        :expect ->
          build(:expectation_evaluation,
            type: :expect,
            name: name,
            return_value: result == :passing
          )

        :expect_same ->
          build(:expectation_evaluation,
            type: :expect_same,
            name: name,
            return_value:
              if result == :passing do
                "same_value"
              else
                Faker.StarWars.character()
              end
          )
      end
    end)
  end
end

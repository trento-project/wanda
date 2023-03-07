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
    %{facts: facts, expectations: expectations, values: values} =
      Enum.find(checks, &(&1.id == check_id))

    expect_same_values =
      Enum.into(expectations, %{}, fn %{name: name} ->
        {name, Faker.StarWars.character()}
      end)

    build(:check_result,
      check_id: check_id,
      agents_check_results:
        Enum.map(check_targets, fn %{agent_id: agent_id} ->
          build(:agent_check_result,
            agent_id: agent_id,
            facts:
              Enum.map(facts, fn %{name: name} ->
                build(:fact, check_id: check_id, name: name)
              end),
            expectation_evaluations:
              build_expectation_evaluations(expectations, result == :passing, expect_same_values),
            values:
              Enum.map(values, fn %{name: name, default: value} ->
                %{name: name, value: value}
              end)
          )
        end),
      expectation_results:
        Enum.map(
          expectations,
          &build(:expectation_result, name: &1.name, type: &1.type, result: result == :passing)
        ),
      result: result
    )
  end

  defp build_expectation_evaluations(expectations, result, expect_same_values) do
    Enum.map(expectations, fn %{name: name, type: type} ->
      case type do
        :expect ->
          build(:expectation_evaluation,
            type: :expect,
            name: name,
            return_value: result
          )

        :expect_same ->
          build(:expectation_evaluation,
            type: :expect_same,
            name: name,
            return_value: build_expect_same_result(result, name, expect_same_values)
          )
      end
    end)
  end

  defp build_expect_same_result(true, name, expect_same_values),
    do: Map.get(expect_same_values, name)

  defp build_expect_same_result(false, _, _), do: Faker.StarWars.character()
end

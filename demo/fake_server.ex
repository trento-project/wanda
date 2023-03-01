defmodule Wanda.Executions.FakeServer do
  @moduledoc """
  Execution server implementation that does not actually execute anything and just
  returns (fake) random results.
  """
  @behaviour Wanda.Executions.ServerBehaviour

  alias Wanda.Executions.FakeEvaluation

  alias Wanda.{
    Catalog,
    Executions
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

    FakeEvaluation.create_complete_fake_execution(execution_id, group_id, targets, checks)

    :ok
  end

  @impl true
  def receive_facts(_execution_id, _group_id, _agent_id, _facts) do
    :ok
  end
end

defmodule Wanda.Executions.FakeServer do
  @moduledoc """
  Execution server implementation that does not actually execute anything and just
  returns (fake) random results.
  """
  @behaviour Wanda.Executions.ServerBehaviour

  alias Wanda.Executions.FakeEvaluation

  alias Wanda.{
    Catalog,
    Executions,
    Messaging
  }

  @default_config [sleep: 2_000]
  @impl true
  def start_execution(execution_id, group_id, targets, env, config \\ @default_config) do
    checks =
      targets
      |> Executions.Target.get_checks_from_targets()
      |> Catalog.get_checks(env)

    checks_ids = Enum.map(checks, & &1.id)

    targets =
      Enum.map(targets, fn %{checks: target_checks} = target ->
        %Executions.Target{target | checks: target_checks -- target_checks -- checks_ids}
      end)

    Executions.create_execution!(execution_id, group_id, targets)
    execution_started = Messaging.Mapper.to_execution_started(execution_id, group_id, targets)
    :ok = Messaging.publish("results", execution_started)

    Process.sleep(Keyword.get(config, :sleep, 2_000))

    build_result = FakeEvaluation.complete_fake_execution(execution_id, group_id, targets, checks)

    Executions.complete_execution!(
      execution_id,
      build_result
    )

    execution_completed = Messaging.Mapper.to_execution_completed(build_result)
    :ok = Messaging.publish("results", execution_completed)
  end

  @impl true
  def receive_facts(_execution_id, _group_id, _agent_id, _facts) do
    :ok
  end
end

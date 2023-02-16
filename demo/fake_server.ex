defmodule Wanda.Executions.FakeServer do
  @behaviour Wanda.Executions.ServerBehaviour

  import Wanda.Factory

  require Logger

  alias Wanda.Executions

  alias Wanda.Executions

  alias Wanda.Messaging

  @impl true
  def start_execution(execution_id, group_id, targets, _env, _config \\ []) do
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
    check_results = build(:check_results_from_targets, targets: targets, result: result)

    build_result =
      build(:result,
        check_results: check_results,
        execution_id: execution_id,
        group_id: group_id,
        result: result
      )

    Executions.complete_execution!(
      execution_id,
      build_result
    )

    execution_completed = Messaging.Mapper.to_execution_completed(build_result)
    :ok = Messaging.publish("results", execution_completed)
  end
end

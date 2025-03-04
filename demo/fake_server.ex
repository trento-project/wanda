defmodule Wanda.Executions.FakeServer do
  @moduledoc """
  Execution server implementation that does not actually execute anything and just
  returns (fake) random results.
  """
  @behaviour Wanda.Executions.ServerBehaviour

  alias Wanda.Catalog.SelectedCheck
  alias Wanda.EvaluationEngine
  alias Wanda.Executions.{Evaluation, FakeGatheredFacts}

  alias Wanda.{
    Catalog,
    Executions,
    Messaging
  }

  @default_config [sleep: 2_000]

  @publisher Wanda.Executions.Messaging.Publisher

  @impl true
  def start_execution(
        execution_id,
        group_id,
        targets,
        target_type,
        env,
        config \\ @default_config
      ) do
    env = Map.put(env, "target_type", target_type)

    selected_checks =
      targets
      |> Executions.Target.get_checks_from_targets()
      |> Catalog.get_checks(env)
      |> Catalog.to_selected_checks(group_id)

    gathered_facts =
      selected_checks
      |> SelectedCheck.extract_specs()
      |> FakeGatheredFacts.get_demo_gathered_facts(targets)

    Executions.create_execution!(execution_id, group_id, targets)
    execution_started = Messaging.Mapper.to_execution_started(execution_id, group_id, targets)
    :ok = Messaging.publish(@publisher, "results", execution_started)

    Process.sleep(Keyword.get(config, :sleep, 2_000))

    evaluation_result =
      Evaluation.execute(
        execution_id,
        group_id,
        selected_checks,
        gathered_facts,
        env,
        EvaluationEngine.new()
      )

    Executions.complete_execution!(
      execution_id,
      evaluation_result
    )

    execution_completed = Messaging.Mapper.to_execution_completed(evaluation_result, target_type)

    :ok = Messaging.publish(@publisher, "results", execution_completed)
  end

  @impl true
  def receive_facts(_execution_id, _group_id, _agent_id, _facts) do
    :ok
  end
end

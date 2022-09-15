defmodule Wanda.Messaging.Mapper do
  @moduledoc """
  Maps domain structures to integration events.
  """

  alias Wanda.Catalog.{Check, Fact}

  alias Wanda.Execution.{
    Result,
    Target
  }

  alias Trento.Checks.V1.{
    ExecutionCompleted,
    FactsGatheringRequested,
    FactsGatheringRequestedTarget,
    FactRequest
  }

  def to_facts_gathering_requested(execution_id, group_id, targets, checks) do
    FactsGatheringRequested.new!(
      execution_id: execution_id,
      group_id: group_id,
      targets: Enum.map(targets, &to_facts_gathering_requested_target(&1, checks))
    )
  end

  def to_execution_completed(%Result{} = result) do
    result
    # TODO: do proper mapping, remove miss
    |> Miss.Map.from_nested_struct()
    |> ExecutionCompleted.new!()
  end

  defp to_facts_gathering_requested_target(
         %Target{agent_id: agent_id, checks: target_checks},
         checks
       ) do
    fact_requests =
      checks
      |> Enum.filter(&(&1.id in target_checks))
      |> Enum.flat_map(fn %Check{id: check_id, facts: facts} ->
        to_fact_requests(check_id, facts)
      end)

    FactsGatheringRequestedTarget.new!(agent_id: agent_id, fact_requests: fact_requests)
  end

  defp to_fact_requests(check_id, facts) do
    Enum.map(facts, fn %Fact{name: name, gatherer: gatherer, argument: argument} ->
      FactRequest.new!(check_id: check_id, name: name, gatherer: gatherer, argument: argument)
    end)
  end
end

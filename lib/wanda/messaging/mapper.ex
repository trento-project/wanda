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
    FactRequest,
    FactsGatheringRequested,
    FactsGatheringRequestedTarget
  }

  def to_facts_gathering_requested(execution_id, group_id, targets, checks) do
    FactsGatheringRequested.new!(
      execution_id: execution_id,
      group_id: group_id,
      targets: Enum.map(targets, &to_facts_gathering_requested_target(&1, checks))
    )
  end

  def to_execution_completed(%Result{
        execution_id: execution_id,
        group_id: group_id,
        result: result
      }) do
    ExecutionCompleted.new!(
      execution_id: execution_id,
      group_id: group_id,
      result: to_result(result)
    )
  end

  defp to_result(:passing), do: :PASSING
  defp to_result(:warning), do: :WARNING
  defp to_result(:critical), do: :CRITICAL

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

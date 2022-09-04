defmodule Wanda.Policy do
  @moduledoc """
  Handles integration events.
  """

  alias Cloudevents.Format.V_1_0.Event, as: CloudEvent
  alias Wanda.Execution.{Fact, Target}

  @execution_requested_event "trento.checks.v1.web.ExecutionRequested"
  @facts_gathered_event "trento.checks.v1.agent.FactsGathered"

  # TODO: move the CloudEvent unwrapping part in the contract repository.
  # we want to receive just the domain event here

  @spec handle_event(CloudEvent.t()) :: :ok | {:error, any}
  def handle_event(%CloudEvent{
        type: @execution_requested_event,
        data: %{"execution_id" => execution_id, "group_id" => agent_id, "targets" => targets}
      }) do
    execution_impl().start_execution(
      execution_id,
      agent_id,
      Enum.map(targets, fn %{"agent_id" => agent_id, "checks" => checks} ->
        %Target{agent_id: agent_id, checks: checks}
      end)
    )
  end

  def handle_event(%CloudEvent{
        type: @facts_gathered_event,
        data: %{"execution_id" => execution_id, "agent_id" => agent_id, "facts_gathered" => facts}
      }) do
    execution_impl().receive_facts(
      execution_id,
      agent_id,
      Enum.map(facts, fn %{"check_id" => check_id, "name" => name, "value" => value} ->
        %Fact{check_id: check_id, name: name, value: value}
      end)
    )
  end

  def handle_event(%CloudEvent{}), do: {:error, :unsupported_event}

  defp execution_impl, do: Application.fetch_env!(:wanda, Wanda.Policy)[:execution_impl]
end

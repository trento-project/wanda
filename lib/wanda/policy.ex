defmodule Wanda.Policy do
  @moduledoc """
  Handles integration events.
  """

  alias Trento.Checks.V1.{
    ExecutionRequested,
    FactsGathered
  }

  alias Wanda.Executions.{
    Fact,
    FactError,
    Target
  }

  require Logger

  @spec handle_event(ExecutionRequested.t() | FactsGathered.t()) :: :ok | {:error, any}
  def handle_event(event) do
    Logger.debug("Handling event #{inspect(event)}")

    handle(event)
  end

  defp handle(%ExecutionRequested{
         execution_id: execution_id,
         group_id: agent_id,
         targets: targets,
         env: env
       }) do
    execution_server_impl().start_execution(
      execution_id,
      agent_id,
      Target.from_list(targets),
      Map.new(env, fn {key, %{kind: {_, value}}} -> {key, value} end)
    )
  end

  defp handle(%FactsGathered{
         execution_id: execution_id,
         group_id: group_id,
         agent_id: agent_id,
         facts_gathered: facts_gathered
       }) do
    execution_server_impl().receive_facts(
      execution_id,
      group_id,
      agent_id,
      Enum.map(facts_gathered, fn %{check_id: check_id, name: name, fact_value: fact_value} ->
        map_gathered_fact(check_id, name, fact_value)
      end)
    )
  end

  defp map_gathered_fact(check_id, name, {:error_value, %{type: type, message: message}}),
    do: %FactError{check_id: check_id, name: name, type: type, message: message}

  defp map_gathered_fact(check_id, name, {:value, %{kind: {_, value}}}),
    do: %Fact{check_id: check_id, name: name, value: value}

  defp execution_server_impl,
    do: Application.fetch_env!(:wanda, Wanda.Policy)[:execution_server_impl]
end

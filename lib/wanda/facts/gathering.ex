defmodule Wanda.Facts.Gathering do
  @moduledoc """
  This module provides Facts Gathering functionalities.
  Triggering targets to actually gather facts and receiving back ouput from the targets.
  """

  require Logger

  @type checks :: [String.t()]

  @spec start(String.t(), String.t(), checks) :: :ok
  def start(execution_id, agent_id, checks) do
    Logger.debug("starting facts gathering on agent_id #{agent_id} - execution: " <> execution_id)

    checks
    |> extract_facts()
    |> initiate_gathering(agent_id, execution_id)

    # TODO: remove me. Useful to simulate receiving gathered facts
    Enum.each(checks, fn check -> simulate_facts_gathering(execution_id, agent_id, check) end)

    :ok
  end

  @spec extract_facts(checks) :: [map]
  defp extract_facts(checks) do
    # given the checks identifiers we can retieve their information (facts gathering DSL mainly)
    # once we have the DSL we can choose whether to parse it in wanda or on the agent_id side

    checks
    |> Enum.flat_map(fn check -> Wanda.ChecksRepository.load_check(check) end)
    # this is parsing the DSL!!! goes somewhere else
    |> Enum.flat_map(fn {_check_key, %{"id" => _id, "facts" => facts}} ->
      # is the check id needed per fact?
      # Enum.map(facts, fn fact -> Map.put(fact, "check_id", id) end)
      facts
    end)

    # |> Enum.map(fn fact -> Wanda.Support.Mappable.to_struct(fact, Fact) end)
  end

  defp initiate_gathering(facts, agent_id, execution_id) do
    Wanda.Facts.Messenger.initiate_facts_gathering(execution_id, agent_id, facts)
  end

  defp simulate_facts_gathering(execution_id, agent_id, check) do
    Task.async(fn ->
      # simulate a real execution by sleeping for a while
      1000..4000 |> Enum.random() |> Process.sleep()

      # Wanda.Facts.Messenger.gather_facts()

      # this would be executed from a Receiver that listens for Agent published messages related to facts gathering
      Wanda.ExecutionServer.gather_facts(
        execution_id,
        %{
          execution_id: execution_id,
          host_id: agent_id,
          check: check,
          gathered_facts:
            "facts for execution " <>
              execution_id <> " agent_id " <> agent_id <> " check " <> check
        }
      )
    end)
  end
end

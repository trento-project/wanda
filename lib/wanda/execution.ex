defmodule Wanda.Execution do
  @moduledoc """
  Represents the execution of the CheckSelection(s) on the target nodes/agents of a cluster
  Orchestrates facts gathering on the targets - issuing execution and receiving back facts - and following check evaluations
  """

  use GenServer

  alias Wanda.Execution.{Expectations, Gathering, State}
  alias Wanda.Messaging.Publisher

  require Logger

  def start_link(execution_id, group_id, targets) do
    GenServer.start_link(
      __MODULE__,
      %State{
        execution_id: execution_id,
        group_id: group_id,
        targets: targets
      },
      name: via_tuple(execution_id)
    )
  end

  def receive_facts(execution_id, agent_id, facts),
    do: execution_id |> via_tuple() |> GenServer.cast({:receive_facts, agent_id, facts})

  @impl true
  def init(%State{execution_id: execution_id} = state) do
    Logger.debug("Starting execution: #{execution_id}", state: inspect(state))

    {:ok, state, {:continue, :start_execution}}
  end

  @impl true
  def handle_continue(
        :start_execution,
        %State{
          execution_id: execution_id,
          targets: _targets
        } = state
      ) do
    :ok = Publisher.initiate_facts_gathering(execution_id, "", "")

    {:noreply, state}
  end

  @impl true
  def handle_cast(
        {:receive_facts, agent_id, facts},
        %State{targets: targets} = state
      ) do
    if Gathering.target?(targets, agent_id) do
      continue_or_complete_execution(state, agent_id, facts)
    else
      Logger.warn("Received facts for agent #{agent_id} but it is not a target of this execution",
        facts: inspect(facts)
      )

      {:noreply, state}
    end
  end

  defp continue_or_complete_execution(
         %State{gathered_facts: gathered_facts, targets: targets} = state,
         agent_id,
         facts
       ) do
    gathered_facts = Gathering.put_gathered_facts(gathered_facts, agent_id, facts)
    state = %State{state | gathered_facts: gathered_facts}

    if Gathering.all_agents_sent_facts?(gathered_facts, targets) do
      Expectations.eval(gathered_facts)

      Publisher.send_execution_results("", "", "")
      {:stop, :normal, state}
    else
      {:noreply, state}
    end
  end

  defp via_tuple(execution_id),
    do: {:via, :global, {__MODULE__, execution_id}}
end

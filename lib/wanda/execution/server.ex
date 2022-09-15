defmodule Wanda.Execution.Server do
  @moduledoc """
  Represents the execution of the CheckSelection(s) on the target nodes/agents of a cluster
  Orchestrates facts gathering on the targets - issuing execution and receiving back facts - and following check evaluations.
  """

  use GenServer

  alias Wanda.Execution.{Evaluation, Gathering, State}
  alias Wanda.Messaging

  require Logger

  @default_timeout 5 * 60 * 1_000

  def start_link(opts) do
    execution_id = Keyword.fetch!(opts, :execution_id)
    config = Keyword.get(opts, :config, [])

    GenServer.start_link(
      __MODULE__,
      %State{
        execution_id: execution_id,
        group_id: Keyword.fetch!(opts, :group_id),
        targets: Keyword.fetch!(opts, :targets),
        checks: Keyword.fetch!(opts, :checks),
        timeout: Keyword.get(config, :timeout, @default_timeout)
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
          group_id: group_id,
          targets: targets,
          checks: checks,
          timeout: timeout
        } = state
      ) do
    facts_gathering_requested =
      Messaging.Mapper.to_facts_gathering_requested(execution_id, group_id, targets, checks)

    :ok = Messaging.publish("agents", facts_gathering_requested)

    Process.send_after(self(), :timeout, timeout)

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

  @impl true
  def handle_info(
        :timeout,
        %State{} = state
      ) do
    :ok = Messaging.publish("results", :timeout)

    {:stop, :normal, state}
  end

  defp continue_or_complete_execution(
         %State{
           execution_id: execution_id,
           group_id: group_id,
           gathered_facts: gathered_facts,
           targets: targets,
           checks: checks,
           agents_gathered: agents_gathered
         } = state,
         agent_id,
         facts
       ) do
    gathered_facts = Gathering.put_gathered_facts(gathered_facts, agent_id, facts)
    agents_gathered = [agent_id | agents_gathered]

    state = %State{state | gathered_facts: gathered_facts, agents_gathered: agents_gathered}

    if Gathering.all_agents_sent_facts?(agents_gathered, targets) do
      result = Evaluation.execute(execution_id, group_id, checks, gathered_facts)
      :ok = Messaging.publish("results", result)

      {:stop, :normal, state}
    else
      {:noreply, state}
    end
  end

  defp via_tuple(execution_id),
    do: {:via, :global, {__MODULE__, execution_id}}
end

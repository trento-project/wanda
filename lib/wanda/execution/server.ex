defmodule Wanda.Execution.Server do
  @moduledoc """
  Represents the execution of the CheckSelection(s) on the target nodes/agents of a cluster
  Orchestrates facts gathering on the targets - issuing execution and receiving back facts - and following check evaluations.
  """

  use GenServer

  alias Wanda.Execution.{Evaluation, Gathering, State}
  alias Wanda.Messaging

  require Logger

  def start_link(opts) do
    execution_id = Keyword.fetch!(opts, :execution_id)

    GenServer.start_link(
      __MODULE__,
      %State{
        execution_id: execution_id,
        group_id: Keyword.fetch!(opts, :group_id),
        targets: Keyword.fetch!(opts, :targets)
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
          execution_id: _execution_id,
          targets: _targets
        } = state
      ) do
    :ok = Messaging.publish("checks.agents.*", "initiate_facts_gathering")

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
         %State{
           execution_id: execution_id,
           group_id: group_id,
           gathered_facts: gathered_facts,
           targets: targets,
           agents_gathered: agents_gathered
         } = state,
         agent_id,
         facts
       ) do
    gathered_facts = Gathering.put_gathered_facts(gathered_facts, agent_id, facts)
    agents_gathered = [agent_id | agents_gathered]

    state = %State{state | gathered_facts: gathered_facts, agents_gathered: agents_gathered}

    if Gathering.all_agents_sent_facts?(agents_gathered, targets) do
      result = Evaluation.execute(execution_id, group_id, gathered_facts)

      :ok = Messaging.publish("checks.execution", result)
      {:stop, :normal, state}
    else
      {:noreply, state}
    end
  end

  # def child_spec(args) do
  #   %{
  #     id: {Execution, execution_id},
  #     start: {Execution, :start_link, [execution_id, group_id, targets]},
  #     restart: :temporary,
  #     type: :worker
  #   }
  # end

  defp via_tuple(execution_id),
    do: {:via, :global, {__MODULE__, execution_id}}
end

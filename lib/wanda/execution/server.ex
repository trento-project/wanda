defmodule Wanda.Execution.Server do
  @moduledoc """
  Represents the execution of the CheckSelection(s) on the target nodes/agents of a cluster
  Orchestrates facts gathering on the targets - issuing execution and receiving back facts - and following check evaluations.
  """

  use GenServer

  alias Wanda.Execution.{Evaluation, FactsRequest, Gathering, State}
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
          execution_id: execution_id,
          group_id: group_id,
          targets: targets
        } = state
      ) do
    case Wanda.Messaging.ProcessCache.get(execution_id) do
      :started ->
        :noop

      nil ->
        Wanda.Messaging.ProcessCache.put(execution_id, :started)

        :ok =
          Messaging.publish(
            "checks.agents.execution.#{execution_id}",
            map_targets_to_facts_request(execution_id, group_id, targets)
          )
    end

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

      # TODO: publish to correct routing key
      :ok = Messaging.publish("checks.execution.completed-#{execution_id}", result)

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

  @spec map_targets_to_facts_request(String.t(), String.t(), [Wanda.Execution.Target.t()]) ::
          FactsRequest.t()
  defp map_targets_to_facts_request(execution_id, group_id, targets) do
    %FactsRequest{
      execution_id: execution_id,
      group_id: group_id,
      targets: Enum.map(targets, & &1.agent_id),
      facts:
        targets
        |> Enum.map(
          &%Wanda.Execution.AgentFacts{
            agent_id: &1.agent_id,
            facts: get_facts_definitions(&1.checks)
          }
        )
    }
  end

  defp get_facts_definitions(checks) do
    checks
    |> Enum.map(&Wanda.Catalog.get_facts/1)
    |> Enum.flat_map(& &1)
  end

  defp via_tuple(execution_id),
    do: {:via, :global, {__MODULE__, execution_id}}
end

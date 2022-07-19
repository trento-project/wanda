defmodule Wanda.Execution.Gathering do
  @moduledoc """
  Facts gathering functional core.
  """

  alias Wanda.Execution.{Fact, Target}

  @doc """
  Adds gathered facts of an agent.
  """
  @spec put_gathered_facts(map(), String.t(), [Fact.t()]) :: map()
  def put_gathered_facts(gathered_facts, agent_id, facts) do
    facts =
      Enum.reduce(facts, %{}, fn %Fact{check_id: check_id, name: name, value: value}, acc ->
        put_in(acc, [Access.key(check_id, %{}), name], value)
      end)

    Map.put(gathered_facts, agent_id, facts)
  end

  @doc """
  Check if an agent is a target of an execution
  """
  @spec target?([Target.t()], String.t()) :: boolean()
  def target?(targets, agent_id),
    do: Enum.any?(targets, &(&1.agent_id == agent_id))

  @doc """
  Check if all the agents have sent the facts
  """
  @spec all_agents_sent_facts?(map(), [Target.t()]) :: boolean()
  def all_agents_sent_facts?(gathered_facts, targets) do
    Enum.all?(targets, fn %Target{agent_id: agent_id} ->
      Map.has_key?(gathered_facts, agent_id)
    end)
  end
end

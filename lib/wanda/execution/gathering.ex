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
    Enum.reduce(
      facts,
      gathered_facts,
      fn %Fact{check_id: check_id, name: name, value: value}, acc ->
        put_in(acc, [Access.key(check_id, %{}), Access.key(agent_id, %{}), name], value)
      end
    )
  end

  @doc """
  Adds timeout data to gathered facts.
  """
  @spec put_gathering_timeouts(map(), [Target.t()]) :: map()
  def put_gathering_timeouts(gathered_facts, timed_out_agents) do
    Enum.reduce(timed_out_agents, gathered_facts, fn %Target{agent_id: agent_id, checks: checks},
                                                     acc ->
      Enum.reduce(checks, acc, fn check_id, accumulator ->
        put_in(accumulator, [Access.key(check_id, %{}), Access.key(agent_id, %{})], :timeout)
      end)
    end)
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
  @spec all_agents_sent_facts?([String.t()], [Target.t()]) :: boolean()
  def all_agents_sent_facts?(agents_gathered, targets) do
    Enum.sort(agents_gathered) ==
      targets
      |> Enum.map(& &1.agent_id)
      |> Enum.sort()
  end
end

defmodule Wanda.Executions.FakeGatheredFacts do
  @moduledoc """
  Module responsible to generate the fake gathered facts from targets
  """

  alias Wanda.Catalog.{Check, Fact}
  alias Wanda.Executions.Fact, as: ExecutionFact
  alias Wanda.Executions.Target

  @fallback_fact_value "some fact value"

  def get_demo_gathered_facts(checks, targets) do
    Enum.reduce(checks, %{}, fn %Check{id: check_id} = check, gathered_facts_map ->
      Map.put(gathered_facts_map, check_id, get_check_facts(check, targets))
    end)
  end

  defp get_check_facts(%Check{id: check_id, facts: facts}, targets) do
    Enum.reduce(targets, %{}, fn %Target{agent_id: agent_id}, agent_gathered_facts ->
      Map.put(agent_gathered_facts, agent_id, get_agent_facts(facts, agent_id, check_id))
    end)
  end

  defp get_agent_facts(facts, agent_id, check_id) do
    Enum.map(facts, fn %Fact{name: name} ->
      %ExecutionFact{
        check_id: check_id,
        name: name,
        value: get_fake_fact_value(check_id, agent_id, name)
      }
    end)
  end

  defp get_fake_fact_value(check_id, agent_id, fact_name) do
    case get_fake_gathered_facts() do
      %{^check_id => %{^fact_name => %{^agent_id => fact_value}}} ->
        fact_value

      _ ->
        @fallback_fact_value
    end
  end

  defp get_fake_gathered_facts do
    Application.fetch_env!(:wanda, :fake_gathered_facts)
  end
end

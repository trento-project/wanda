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
    with {:ok, target_refs, fake_facts} <- read_from_yaml_config(),
         {:ok, target_ref} <- get_target_reference(target_refs, agent_id),
         {:ok, fact_value} <- get_fake_value_from_map(fake_facts, check_id, fact_name, target_ref) do
      fact_value
    else
      {:error, _reason} ->
        # add logger later
        @fallback_fact_value
    end
  end

  defp read_from_yaml_config do
    case YamlElixir.read_from_file(get_fake_gathered_facts_config()) do
      {:ok, %{"targets" => target_refs, "facts" => fake_facts}} -> {:ok, target_refs, fake_facts}
      error -> error
    end
  end

  defp get_fake_value_from_map(fake_facts, check_id, fact_name, target_ref) do
    case fake_facts do
      %{^check_id => %{^fact_name => %{^target_ref => fact_value}}} ->
        {:ok, fact_value}

      _ ->
        {:error, :value_not_found}
    end
  end

  defp get_target_reference(target_refs, agent_id) do
    case Enum.find(target_refs, fn {_, target_id} -> target_id == agent_id end) do
      nil -> {:error, :target_ref_not_found}
      found_target -> {:ok, elem(found_target, 0)}
    end
  end

  defp get_fake_gathered_facts_config do
    Application.fetch_env!(:wanda, __MODULE__)[:demo_facts_config]
  end
end

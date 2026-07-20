# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: Apache-2.0

defmodule Wanda.Executions.FakeGatheredFacts do
  @moduledoc """
  Synthesizes the fake value of a single requested fact for the demo/dev facts
  gathering source.

  This module deliberately knows nothing about *which* facts to gather — that
  decision belongs to `Wanda.Messaging.Mapper.to_facts_gathering_requested/4`,
  the single source of truth shared with the production (AMQP) path. Here we only
  answer "what value should this one `(check, agent, fact)` have", so the demo
  path cannot drift from production on request contents.
  """

  require Logger

  @fallback_fact_value "some fact value"

  @doc """
  Returns the synthetic value for a single `(check, agent, fact)`, from the demo
  facts yaml config, falling back to a default when not configured/readable.
  """
  @spec fake_value(String.t(), String.t(), String.t()) :: term()
  def fake_value(check_id, agent_id, fact_name) do
    with {:ok, target_refs, fake_facts} <- read_from_yaml_config(),
         {:ok, target_ref} <- get_target_reference(target_refs, agent_id),
         {:ok, fact_value} <- get_fake_value_from_map(fake_facts, check_id, fact_name, target_ref) do
      fact_value
    else
      {:error, reason} ->
        Logger.warning(
          "Could not get fact '#{fact_name}'. Falling back to default value.",
          check_id: inspect(check_id),
          fact_name: inspect(fact_name),
          agent_id: inspect(agent_id),
          reason: inspect(reason)
        )

        @fallback_fact_value
    end
  end

  defp read_from_yaml_config do
    case YamlElixir.read_from_file(get_fake_gathered_facts_config()) do
      {:ok, %{"targets" => target_refs, "facts" => fake_facts}} ->
        {:ok, target_refs, fake_facts}

      error ->
        error
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
      nil ->
        {:error, :target_ref_not_found}

      found_target ->
        {:ok, elem(found_target, 0)}
    end
  end

  defp get_fake_gathered_facts_config do
    Application.fetch_env!(:wanda, __MODULE__)[:demo_facts_config]
  end
end

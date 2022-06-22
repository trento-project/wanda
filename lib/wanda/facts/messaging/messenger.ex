defmodule Wanda.Facts.Messenger do
  @moduledoc """
  Facts Messenger entrypoint module.
  """

  @behaviour Wanda.Facts.Messenger.Gen

  def gather_facts() do
    adapter().gather_facts()
  end

  def initiate_facts_gathering(execution_id, agent_id, facts) do
    adapter().initiate_facts_gathering(execution_id, agent_id, facts)
  end

  defp adapter,
    do: Application.fetch_env!(:wanda, __MODULE__)[:adapter]
end

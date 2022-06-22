defmodule Wanda.Facts.Messenger.Mock do
  @moduledoc """
  A Mocked Messenger for dev/test purposes
  """

  @behaviour Wanda.Facts.Messenger.Gen

  require Logger

  def initiate_facts_gathering(execution_id, agent_id, facts) do
    Logger.debug(
      "notifying the target #{agent_id} to start gathering facts for exeution #{execution_id}"
    )

    payload =
      Jason.encode!(%{
        meta: %{
          execution_id: execution_id,
          agent_id: agent_id
        },
        facts: facts
      })

    Logger.debug(payload)
  end

  def gather_facts() do
    Wanda.receive_gathered_facts()
  end
end

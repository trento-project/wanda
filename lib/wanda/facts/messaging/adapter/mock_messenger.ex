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

    # move this to actual rabbit adapter
    dsn = "amqp://wanda:wanda@localhost:5672"
    # dsn = "amqp://wanda:wanda@7.tcp.eu.ngrok.io:19381"
    {:ok, connection} = AMQP.Connection.open(dsn)
    {:ok, channel} = AMQP.Channel.open(connection)
    AMQP.Queue.declare(channel, "gather_facts")
    AMQP.Basic.publish(channel, "", "some-agent", payload)
    AMQP.Connection.close(connection)

    Logger.debug(payload)
  end

  def gather_facts() do
    Wanda.receive_gathered_facts()
  end
end

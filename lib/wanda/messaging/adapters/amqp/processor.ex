defmodule Wanda.Messaging.Adapters.AMQP.Processor do
  @moduledoc """
  AMQP processor.
  """

  @behaviour GenRMQ.Processor

  require Logger

  alias Trento.Contracts
  alias Wanda.Policy

  def process(%GenRMQ.Message{payload: payload} = message) do
    Logger.debug("Received message: #{inspect(message)}")

    case Contracts.from_event(payload) do
      {:ok, event} -> Policy.handle_event(event)
      {:error, reason} -> {:error, reason}
    end
  end
end

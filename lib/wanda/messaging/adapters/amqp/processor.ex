defmodule Wanda.Messaging.Adapters.AMQP.Processor do
  @moduledoc """
  AMQP processor.
  """

  alias Trento.Contracts
  alias Wanda.Policy

  @behaviour GenRMQ.Processor

  require Logger

  def process(%GenRMQ.Message{payload: payload}) do
    case Contracts.from_event(payload) do
      {:ok, event} -> Policy.handle_event(event)
      {:error, reason} -> {:error, reason}
    end
  end
end

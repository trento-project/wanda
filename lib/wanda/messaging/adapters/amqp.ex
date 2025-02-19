defmodule Wanda.Messaging.Adapters.AMQP do
  @moduledoc """
  AMQP adapter
  """

  @behaviour Wanda.Messaging.Adapters.Behaviour

  @impl true
  def publish(publisher, routing_key, message) do
    message
    |> Trento.Contracts.to_event(source: "github.com/trento-project/wanda")
    |> publisher.publish_message(routing_key)
  end
end

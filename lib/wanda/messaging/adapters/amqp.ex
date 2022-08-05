defmodule Wanda.Messaging.Adapters.AMQP do
  @moduledoc """
  AMQP adapter
  """

  @behaviour Wanda.Messaging.Adapters.Behaviour

  alias Wanda.Messaging.Adapters.AMQP.Publisher

  @impl true
  def publish(routing_key, message), do: Publisher.publish_message(message, routing_key)

  @impl true
  def child_spec do
    [
      Wanda.Messaging.Adapters.AMQP.Consumer,
      Wanda.Messaging.Adapters.AMQP.Publisher
    ]
  end
end

defmodule Wanda.Messaging.Adapters.AMQP do
  @moduledoc """
  AMQP adapter
  """

  @behaviour Wanda.Messaging.Adapters.Behaviour

  alias Wanda.Messaging.Adapters.AMQP.Publisher

  @impl true

  def publish(routing_key, message) do
    message
    |> Trento.Contracts.to_event(source: "github.com/trento-project/wanda")
    |> Publisher.publish_message(routing_key)
  end
end

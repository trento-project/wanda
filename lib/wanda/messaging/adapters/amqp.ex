defmodule Wanda.Messaging.Adapters.AMQP do
  @moduledoc """
  AMQP adapter
  """

  @behaviour Wanda.Messaging.Adapters.Behaviour

  alias Wanda.Messaging.Adapters.AMQP.Publisher

  @impl true

  # FIXME: fix Trento.Contracts.to_event/2
  @dialyzer {:nowarn_function, publish: 2}

  def publish(routing_key, message) do
    message
    |> Trento.Contracts.to_event(source: "wanda")
    |> Publisher.publish_message(routing_key)
  end
end

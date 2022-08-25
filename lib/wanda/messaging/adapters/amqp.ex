defmodule Wanda.Messaging.Adapters.AMQP do
  @moduledoc """
  AMQP adapter
  """

  @behaviour Wanda.Messaging.Adapters.Behaviour

  alias Wanda.Messaging.Adapters.AMQP.Publisher

  alias Wanda.Messaging.Mapper

  @impl true
  def publish(routing_key, message),
    do:
      message
      |> Mapper.to_json()
      |> Publisher.publish_message(routing_key)
end

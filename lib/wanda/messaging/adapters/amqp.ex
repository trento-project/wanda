defmodule Wanda.Messaging.Adapters.AMQP do
  @moduledoc """
  AMQP adapter
  """

  @behaviour Wanda.Messaging.Adapters.Behaviour

  @impl true
  def publish(publisher, routing_key, message, opts \\ []) do
    to_event_opts =
      Keyword.merge(
        [source: "github.com/trento-project/wanda"],
        opts
      )

    message
    |> Trento.Contracts.to_event(to_event_opts)
    |> publisher.publish_message(routing_key)
  end
end

defmodule Wanda.Messaging.Adapters.AMQP.Publisher do
  @moduledoc """
  AMQP publisher.
  """

  @behaviour GenRMQ.Publisher

  require Logger

  def init do
    Application.fetch_env!(:wanda, :messaging)[:amqp][:publisher]
  end

  def start_link(_opts), do: GenRMQ.Publisher.start_link(__MODULE__, name: __MODULE__)

  def publish_message(message, routing_key \\ "") do
    Logger.info("Publishing message #{inspect(message)} to #{routing_key}")

    # The agent expects content-type: application/cloudevents+json
    # as a header of the amqp message.
    # is it necessary?
    GenRMQ.Publisher.publish(__MODULE__, message, routing_key,
      content_type: "application/cloudevents+json",
      persistent: true
    )
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end
end

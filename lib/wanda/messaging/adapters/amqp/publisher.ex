defmodule Wanda.Messaging.Adapters.AMQP.Publisher do
  @moduledoc """
  AMQP publisher.
  """

  defmacro __using__(opts) do
    id = Keyword.fetch!(opts, :id)
    name = Keyword.fetch!(opts, :name)

    quote do
      @behaviour GenRMQ.Publisher

      alias Trento.Contracts

      require Logger

      def init do
        Application.fetch_env!(:wanda, Wanda.Messaging.Adapters.AMQP)[unquote(name)][:publisher]
      end

      def start_link(_opts) do
        GenRMQ.Publisher.start_link(__MODULE__, name: via_tuple())
      end

      def publish_message(message, routing_key \\ "") do
        Logger.info("Publishing message #{inspect(message)}")

        GenRMQ.Publisher.publish(via_tuple(), message, routing_key, [
          {:content_type, Contracts.content_type()}
        ])
      end

      def child_spec(opts) do
        %{
          id: unquote(id),
          name: via_tuple(),
          start: {__MODULE__, :start_link, [opts]},
          type: :worker,
          restart: :permanent,
          shutdown: 500
        }
      end

      defp via_tuple,
        do: {:via, :global, {__MODULE__, unquote(name)}}
    end
  end
end

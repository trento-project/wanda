defmodule Wanda.Messaging.Adapters.AMQP.Consumer do
  @moduledoc """
  AMQP consumer.
  """

  defmacro __using__(opts) do
    id = Keyword.fetch!(opts, :id)
    name = Keyword.fetch!(opts, :name)

    quote do
      @behaviour GenRMQ.Consumer

      require Logger

      @impl GenRMQ.Consumer
      def init do
        config =
          Application.fetch_env!(:wanda, Wanda.Messaging.Adapters.AMQP)[unquote(name)][:consumer]

        Keyword.merge(config,
          retry_delay_function: fn attempt -> :timer.sleep(2000 * attempt) end
        )
      end

      @spec start_link(any) :: {:error, any} | {:ok, pid}
      def start_link(_opts) do
        GenRMQ.Consumer.start_link(__MODULE__, name: via_tuple())
      end

      @impl GenRMQ.Consumer
      def consumer_tag, do: "wanda_#{unquote(name)}"

      @impl GenRMQ.Consumer
      def handle_message(%GenRMQ.Message{} = message) do
        case processor().process(message) do
          :ok -> GenRMQ.Consumer.ack(message)
          {:error, reason} -> handle_error(message, reason)
        end
      end

      @impl GenRMQ.Consumer
      def handle_error(message, reason) do
        Logger.error("Unable to handle message: #{inspect(message)}. Reason: #{inspect(reason)}")

        GenRMQ.Consumer.reject(message)
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

      defp processor,
        do:
          Application.fetch_env!(:wanda, Wanda.Messaging.Adapters.AMQP)[unquote(name)][:processor]

      defp via_tuple,
        do: {:via, :global, {__MODULE__, unquote(name)}}
    end
  end
end

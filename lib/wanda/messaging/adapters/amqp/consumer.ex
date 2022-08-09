defmodule Wanda.Messaging.Adapters.AMQP.Consumer do
  @moduledoc """
  AMQP consumer.
  """

  alias Wanda.Messaging.Mapper
  alias Wanda.Policy

  @behaviour GenRMQ.Consumer

  require Logger

  @impl GenRMQ.Consumer
  def init do
    config = Application.fetch_env!(:wanda, :messaging)[:amqp][:consumer]

    Keyword.merge(config, retry_delay_function: fn attempt -> :timer.sleep(2000 * attempt) end)
  end

  @spec start_link(any) :: {:error, any} | {:ok, pid}
  def start_link(_opts), do: GenRMQ.Consumer.start_link(__MODULE__, name: __MODULE__)

  @impl GenRMQ.Consumer
  def consumer_tag, do: "wanda"

  @impl GenRMQ.Consumer
  def handle_message(%GenRMQ.Message{payload: payload} = message) do
    case Mapper.from_json(payload) do
      {:ok, event} -> Policy.handle_event(event)
      {:error, reason} -> handle_error(message, reason)
    end
  end

  @impl GenRMQ.Consumer
  def handle_error(message, _reason) do
    Logger.error("Unable to handle message", message: inspect(message))
    GenRMQ.Consumer.reject(message, true)
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

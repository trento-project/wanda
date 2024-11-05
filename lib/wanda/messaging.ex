defmodule Wanda.Messaging do
  @moduledoc """
  Publishes messages to the message bus
  """

  @spec publish(String.t(), any()) :: :ok | {:error, any()}
  def publish(topic, message) do
    adapter().publish(topic, message)
  end

  @spec publish_signed(String.t(), any()) :: :ok | {:error, any()}
  def publish_signed(topic, message) do
    adapter().publish_signed(topic, message)
  end

  defp adapter,
    do: Application.fetch_env!(:wanda, :messaging)[:adapter]
end

defmodule Wanda.Messaging do
  @moduledoc """
  Publishes messages to the message bus
  """

  @spec publish(module(), String.t(), any(), Keyword.t()) :: :ok | {:error, any()}
  def publish(publisher, topic, message, opts \\ []) do
    adapter().publish(publisher, topic, message, opts)
  end

  defp adapter,
    do: Application.fetch_env!(:wanda, :messaging)[:adapter]
end

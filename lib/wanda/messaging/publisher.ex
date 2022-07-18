defmodule Wanda.Messaging.Publisher do
  @moduledoc """
  Publishes messages to the message bus
  """

  def initiate_facts_gathering(_, _, _), do: adapter().publish("stuff")
  def send_execution_results(_, _, _), do: adapter().publish("stuff2")

  defp adapter,
    do: Application.fetch_env!(:wanda, __MODULE__)[:adapter]
end

defmodule Wanda.Support.PublisherStub do
  @moduledoc nil

  @behaviour Wanda.Messaging.Adapters.Behaviour

  @impl true
  def publish(_), do: :ok
end

defmodule Wanda.Support.PublisherStub do
  @moduledoc false

  @behaviour Wanda.Messaging.Adapters.Behaviour

  @impl true
  def publish(_), do: :ok
end

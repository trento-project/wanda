defmodule Wanda.Support.PublisherStub do
  @moduledoc false

  @behaviour Wanda.Messaging.Adapters.Behaviour

  @impl true
  def publish(_, _), do: :ok

  @impl true
  def child_spec, do: []
end

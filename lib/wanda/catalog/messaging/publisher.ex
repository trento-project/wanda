defmodule Wanda.Catalog.Messaging.Publisher do
  @moduledoc """
  Catalog messaging publisher module
  """

  use Wanda.Messaging.Adapters.AMQP.Publisher, id: __MODULE__, name: :catalog
end

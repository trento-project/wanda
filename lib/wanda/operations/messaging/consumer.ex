defmodule Wanda.Operations.Messaging.Consumer do
  @moduledoc """
  Operations messagging consumer module
  """

  use Wanda.Messaging.Adapters.AMQP.Consumer, id: __MODULE__, name: :operations
end

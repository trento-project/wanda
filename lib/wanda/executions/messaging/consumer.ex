defmodule Wanda.Executions.Messaging.Consumer do
  @moduledoc """
  Executions messagging consumer module
  """

  use Wanda.Messaging.Adapters.AMQP.Consumer, id: __MODULE__, name: :checks
end

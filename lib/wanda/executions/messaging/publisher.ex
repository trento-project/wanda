defmodule Wanda.Executions.Messaging.Publisher do
  @moduledoc """
  Executions messagging publisher module
  """

  use Wanda.Messaging.Adapters.AMQP.Publisher, id: __MODULE__, name: :checks
end

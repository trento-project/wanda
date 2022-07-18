defmodule Wanda.Messaging.Adapters.Behaviour do
  @moduledoc nil

  @callback publish(message :: any) :: :ok
end

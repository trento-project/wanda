defmodule Wanda.Messaging.Adapters.Behaviour do
  @moduledoc false

  @callback publish(message :: any) :: :ok
end

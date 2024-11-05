defmodule Wanda.Messaging.Adapters.Behaviour do
  @moduledoc false

  @callback publish(topic :: String.t(), message :: any) :: :ok | {:error, any()}

  @callback publish_signed(topic :: String.t(), message :: any) :: :ok | {:error, any()}
end

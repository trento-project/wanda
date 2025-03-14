defmodule Wanda.Messaging.Adapters.Behaviour do
  @moduledoc false

  @callback publish(
              publisher :: module(),
              topic :: String.t(),
              message :: any,
              opts :: Keyword.t()
            ) ::
              :ok | {:error, any()}
end

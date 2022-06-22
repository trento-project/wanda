defmodule Wanda.Facts.Messenger.Gen do
  @moduledoc """
  A Messenger that is responsible for communication with the targets in regards to initiating facts gathering and receiving gathered facts
  """

  @callback initiate_facts_gathering(
              execution_id :: String.t(),
              agent_id :: String.t(),
              facts :: any
            ) :: any

  @callback gather_facts() :: any
end

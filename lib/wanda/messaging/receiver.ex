defmodule Wanda.Messaging.Receiver.Gen do
  @moduledoc """
  Behaviour for receiving Messages from a remote publisher, aka the hosts in the target infrastructure
  """

  @callback receive_gathered_facts(facts_gathered_on_a_target_node :: any) ::
              :ok | {:error, any}
end

defmodule Wanda.Messaging.Publisher.Gen do
  @moduledoc """
  Behaviour for publishing Messages towards a Receiver in the target infrastructure
  """

  # TODO: better define the name and shape of facts_to_be_gathered_on_a_target_node
  @callback publish_facts_gathering(facts_to_be_gathered_on_a_target_node :: any) ::
              :ok | {:error, any}
end

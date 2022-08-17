defmodule Wanda.Execution.Behaviour do
  @moduledoc """
  Execution API behaviour.
  """

  alias Wanda.Execution.Fact

  @callback receive_facts(execution_id :: String.t(), agent_id :: String.t(), [Fact.t()]) ::
              :ok | {:error, any}
end

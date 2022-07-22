defmodule Wanda.Execution.AgentCheckResult do
  @moduledoc """
  Represents the result of a check on a specific agent.
  """

  alias Wanda.Execution.AgentExpectationResult

  defstruct [
    :agent_id,
    :facts,
    :expectations_result
  ]

  @type t :: %__MODULE__{
          agent_id: String.t(),
          facts: %{(name :: String.t()) => result :: any()},
          expectations_result: [AgentExpectationResult.t()]
        }
end

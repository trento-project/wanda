defmodule Wanda.Execution.Result do
  @moduledoc """
  Represents the result of an execution on a specific agent.
  """

  alias Wanda.Execution.CheckResult

  defstruct [
    :agent_id,
    :checks_results
  ]

  @type t :: %__MODULE__{
          agent_id: String.t(),
          checks_results: [CheckResult.t()]
        }
end

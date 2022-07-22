defmodule Wanda.Execution.CheckResult do
  alias Wanda.Execution.AgentCheckResult

  defstruct [
    :check_id,
    :expectations_result,
    :agents_result,
    :result
  ]

  @type t :: %__MODULE__{
          check_id: String.t(),
          expectations_result: [ExpectationResult.t()],
          agents_result: [AgentCheckResult.t()],
          result: :passing | :warning | :critical
        }
end

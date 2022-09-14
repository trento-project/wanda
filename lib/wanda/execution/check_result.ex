defmodule Wanda.Execution.CheckResult do
  @moduledoc """
  Represents the result of a check.
  """

  alias Wanda.Execution.{AgentCheckError, AgentCheckResult, ExpectationResult}

  @derive Jason.Encoder
  defstruct [
    :check_id,
    :expectation_results,
    :agents_check_results,
    :result
  ]

  @type t :: %__MODULE__{
          check_id: String.t(),
          expectation_results: [ExpectationResult.t()],
          agents_check_results: [AgentCheckResult.t() | AgentCheckError.t()],
          result: :passing | :warning | :critical
        }
end

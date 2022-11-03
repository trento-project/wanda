defmodule Wanda.Executions.CheckResult do
  @moduledoc """
  Represents the result of a check.
  """

  alias Wanda.Executions.{AgentCheckError, AgentCheckResult, ExpectationResult}

  @derive Jason.Encoder
  defstruct [
    :check_id,
    :result,
    agents_check_results: [],
    expectation_results: []
  ]

  @type t :: %__MODULE__{
          check_id: String.t(),
          expectation_results: [ExpectationResult.t()],
          agents_check_results: [AgentCheckResult.t() | AgentCheckError.t()],
          result: :passing | :warning | :critical
        }
end

defmodule Wanda.Execution.AgentCheckResult do
  @moduledoc """
  Represents the result of a check on a specific agent.
  """

  alias Wanda.Execution.{
    ExpectationEvaluation,
    ExpectationEvaluationError,
    Fact,
    Value
  }

  @derive Jason.Encoder
  defstruct [
    :agent_id,
    :facts,
    :values,
    :expectation_evaluations
  ]

  @type t :: %__MODULE__{
          agent_id: String.t(),
          facts: [Fact.t()],
          values: [Value.t()],
          expectation_evaluations: [ExpectationEvaluation.t() | ExpectationEvaluationError.t()]
        }
end

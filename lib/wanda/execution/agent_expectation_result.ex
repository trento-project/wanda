defmodule Wanda.Execution.AgentExpectationResult do
  @moduledoc """
  Represents the result of an expectation of a specific agent.
  """

  defstruct [
    :name,
    :result,
    :type
  ]

  @type t :: %__MODULE__{
          name: String.t(),
          result: boolean() | :fact_missing_error | :illegal_expression_error,
          type: :expect | :expect_same
        }
end

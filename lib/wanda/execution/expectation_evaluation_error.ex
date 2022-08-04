defmodule Wanda.Execution.ExpectationEvaluationError do
  @moduledoc """
  Represents an error occurred during the evaluation of an expectation.
  """

  defstruct [
    :name,
    :message,
    :type
  ]

  @type t :: %__MODULE__{
          name: String.t(),
          message: String.t(),
          type: :fact_missing_error | :illegal_expression_error
        }
end

defmodule Wanda.Execution.GroupExpectationResult do
  @moduledoc """
  Represents the result of an expectation.
  """

  defstruct [
    :name,
    :type,
    :result,
    :local_result,
    :result
  ]

  @type t :: %__MODULE__{
          name: String.t(),
          type: :any | :all | :none,
          local_result: boolean() | :fact_missing_error | :illegal_expression_error,
          result: any()
        }
end

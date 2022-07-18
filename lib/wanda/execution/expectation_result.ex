defmodule Wanda.Execution.ExpectationResult do
  @moduledoc """
  Represents the result of an expectation.
  """

  defstruct [
    :name,
    :result
  ]

  @type t :: %__MODULE__{
          name: String.t(),
          result: boolean() | :fact_missing_error | :illegal_expression_error
        }
end

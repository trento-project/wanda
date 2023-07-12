defmodule Wanda.Executions.ExpectationEvaluationError do
  @moduledoc """
  Represents an error occurred during the evaluation of an expectation.
  """

  @derive Jason.Encoder
  defstruct [
    :name,
    :message,
    :type
  ]

  @type t :: %__MODULE__{
          name: String.t(),
          message: String.t(),
          type: Rhai.Error.t()
        }
end

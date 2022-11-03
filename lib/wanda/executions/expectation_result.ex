defmodule Wanda.Executions.ExpectationResult do
  @moduledoc """
  Represents the result of an expectation.
  """

  @derive Jason.Encoder
  defstruct [
    :name,
    :result,
    :type
  ]

  @type t :: %__MODULE__{
          name: String.t(),
          result: boolean(),
          type: :expect | :expect_same
        }
end

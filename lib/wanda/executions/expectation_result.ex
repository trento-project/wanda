defmodule Wanda.Executions.ExpectationResult do
  @moduledoc """
  Represents the result of an expectation.
  """

  @derive Jason.Encoder
  defstruct [
    :name,
    :result,
    :type,
    :failure_message
  ]

  @type t :: %__MODULE__{
          name: String.t(),
          result: boolean() | :passing | :warning | :critical,
          type: :expect | :expect_same | :expect_enum,
          failure_message: String.t() | nil
        }
end

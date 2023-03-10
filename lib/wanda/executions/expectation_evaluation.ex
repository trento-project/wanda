defmodule Wanda.Executions.ExpectationEvaluation do
  @moduledoc """
  Represents the evaluation of an expectation.
  """

  @derive Jason.Encoder
  defstruct [
    :name,
    :return_value,
    :type,
    :failure_message
  ]

  @type t :: %__MODULE__{
          name: String.t(),
          return_value: number() | boolean() | String.t(),
          type: :expect | :expect_same,
          failure_message: String.t() | nil
        }
end

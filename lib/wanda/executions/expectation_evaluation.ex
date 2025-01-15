defmodule Wanda.Executions.ExpectationEvaluation do
  @moduledoc """
  Represents the evaluation of an expectation.
  """

  require Wanda.Catalog.Enums.ExpectType, as: ExpectType
  require Wanda.Expectations.Enums.Result, as: Result

  @derive Jason.Encoder
  defstruct [
    :name,
    :return_value,
    :type,
    :failure_message
  ]

  @type t :: %__MODULE__{
          name: String.t(),
          return_value: number() | boolean() | String.t() | Result.t(),
          type: ExpectType.t(),
          failure_message: String.t() | nil
        }
end

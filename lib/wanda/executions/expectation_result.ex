defmodule Wanda.Executions.ExpectationResult do
  @moduledoc """
  Represents the result of an expectation.
  """

  require Wanda.Catalog.Enums.ExpectType, as: ExpectType
  require Wanda.Expectations.Enums.Result, as: Result

  @derive Jason.Encoder
  defstruct [
    :name,
    :result,
    :type,
    :failure_message
  ]

  @type t :: %__MODULE__{
          name: String.t(),
          result: boolean() | Result.t(),
          type: ExpectType.t(),
          failure_message: String.t() | nil
        }
end

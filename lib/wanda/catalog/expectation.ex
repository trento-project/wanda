defmodule Wanda.Catalog.Expectation do
  @moduledoc """
  Represents an expectation.
  """

  require Wanda.Catalog.Enums.ExpectType, as: ExpectType

  @derive Jason.Encoder
  defstruct [:name, :type, :expression, :failure_message, :warning_message]

  @type t :: %__MODULE__{
          name: String.t(),
          type: ExpectType.t(),
          expression: String.t(),
          failure_message: String.t(),
          warning_message: String.t()
        }
end

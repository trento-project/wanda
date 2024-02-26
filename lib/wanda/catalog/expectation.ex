defmodule Wanda.Catalog.Expectation do
  @moduledoc """
  Represents an expectation.
  """

  @derive Jason.Encoder
  defstruct [:name, :type, :expression, :failure_message, :warning_message]

  @type t :: %__MODULE__{
          name: String.t(),
          type: :expect | :expect_same | :expect_enum,
          expression: String.t(),
          failure_message: String.t(),
          warning_message: String.t()
        }
end

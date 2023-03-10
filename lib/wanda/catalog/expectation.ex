defmodule Wanda.Catalog.Expectation do
  @moduledoc """
  Represents an expectation.
  """

  @derive Jason.Encoder
  defstruct [:name, :type, :expression, :failure_message]

  @type t :: %__MODULE__{
          name: String.t(),
          type: :expect | :expect_same,
          expression: String.t(),
          failure_message: String.t()
        }
end

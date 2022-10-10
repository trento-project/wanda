defmodule Wanda.Catalog.Expectation do
  @moduledoc """
  Represents an expectation.
  """

  @derive Jason.Encoder
  defstruct [:name, :type, :expression]

  @type t :: %__MODULE__{
          name: String.t(),
          type: :expect | :expect_same,
          expression: String.t()
        }
end

defmodule Wanda.Catalog.Condition do
  @moduledoc """
  Represents a condition.
  """

  defstruct [:value, :expression]

  @type t :: %__MODULE__{
          value: boolean() | number() | String.t(),
          expression: String.t()
        }
end

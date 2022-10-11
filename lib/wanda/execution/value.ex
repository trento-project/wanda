defmodule Wanda.Execution.Value do
  @moduledoc """
  Represents a Value used in expectation evaluation.
  This value has been already determined given the conditions in check definition.
  """

  @derive Jason.Encoder
  defstruct [
    :name,
    :value
  ]

  @type t :: %__MODULE__{
          name: String.t(),
          value: boolean() | number() | String.t()
        }
end

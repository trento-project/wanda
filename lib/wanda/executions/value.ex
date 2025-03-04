defmodule Wanda.Executions.Value do
  @moduledoc """
  Represents a Value used in expectation evaluation.
  This value has been already determined given the conditions in check definition.
  """

  @derive Jason.Encoder
  defstruct [
    :name,
    :value,
    :customized
  ]

  @type t :: %__MODULE__{
          name: String.t(),
          value: boolean() | number() | String.t(),
          customized: boolean()
        }
end

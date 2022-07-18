defmodule Wanda.Execution.Fact do
  @moduledoc """
  A fact is a piece of information that was gathered from a target.
  """

  defstruct [
    :check_id,
    :name,
    :value
  ]

  @type t :: %__MODULE__{
          check_id: String.t(),
          name: String.t(),
          value: String.t()
        }
end

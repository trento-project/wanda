defmodule Wanda.Execution.FactError do
  @moduledoc """
  Fact with an error.
  """

  @derive Jason.Encoder
  defstruct [
    :check_id,
    :name,
    :type,
    :message
  ]

  @type t :: %__MODULE__{
          check_id: String.t(),
          name: String.t(),
          type: String.t(),
          message: String.t()
        }
end

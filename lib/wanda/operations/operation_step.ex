defmodule Wanda.Operations.OperationStep do
  @moduledoc """

  """

  defstruct [
    :id,
    :operator,
    :predicate
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          operator: String.t(),
          predicate: String.t()
        }
end

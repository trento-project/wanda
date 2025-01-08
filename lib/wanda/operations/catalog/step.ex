defmodule Wanda.Operations.Catalog.Step do
  @moduledoc """
  A individual operation step running a single operator.
  The predicate is a rhai execution that returns true/false
  defining if the step needs to be executed in a certain agent.
  """

  defstruct [
    :operator,
    :predicate
  ]

  @type t :: %__MODULE__{
          operator: String.t(),
          predicate: String.t()
        }
end

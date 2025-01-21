defmodule Wanda.Operations.Catalog.Step do
  @moduledoc """
  A individual operation step running a single operator.
  The predicate is a rhai execution that returns true/false
  defining if the step needs to be executed in a certain agent.
  """

  @default_timeout 5 * 60 * 1_000

  defstruct [
    :operator,
    :predicate,
    timeout: @default_timeout
  ]

  @type t :: %__MODULE__{
          operator: String.t(),
          predicate: String.t(),
          timeout: integer()
        }
end

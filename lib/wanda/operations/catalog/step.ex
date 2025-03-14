defmodule Wanda.Operations.Catalog.Step do
  @moduledoc """
  A individual operation step running a single operator.
  The predicate is a rhai execution that returns true/false
  defining if the step needs to be executed in a certain agent.

  The timeout must be defined in milliseconds
  """

  @default_timeout 5 * 60 * 1_000

  @derive Jason.Encoder
  defstruct [
    :name,
    :operator,
    :predicate,
    timeout: @default_timeout
  ]

  @type t :: %__MODULE__{
          name: String.t(),
          operator: String.t(),
          predicate: String.t(),
          timeout: non_neg_integer()
        }
end

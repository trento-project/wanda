defmodule Wanda.Operations.Catalog.Operation do
  @moduledoc """
  An operation is a set of actions executed step by step in agents to apply
  permanent changes in them.
  """

  alias Wanda.Operations.Catalog.Step

  defstruct [
    :id,
    :name,
    :description,
    :steps,
    required_args: []
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          description: String.t(),
          steps: [Step.t()],
          required_args: [String.t()]
        }
end

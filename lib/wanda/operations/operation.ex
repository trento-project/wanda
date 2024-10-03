defmodule Wanda.Operations.Operation do
  @moduledoc """

  """

  alias Wanda.Operations.OperationStep

  defstruct [
    :id,
    :name,
    :steps,
    required_args: []
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          steps: [OperationStep.t()],
          required_args: [String.t()]
        }
end

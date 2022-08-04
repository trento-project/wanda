defmodule Wanda.Execution.State do
  @moduledoc """
  State of an execution.
  """

  alias Wanda.Execution.Target

  defstruct [
    :execution_id,
    :group_id,
    targets: [],
    gathered_facts: %{},
    agents_gathered: []
  ]

  @type t :: %__MODULE__{
          execution_id: String.t(),
          group_id: String.t(),
          targets: [Target.t()],
          gathered_facts: map(),
          agents_gathered: [String.t()]
        }
end

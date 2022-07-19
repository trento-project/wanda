defmodule Wanda.Execution.State do
  @moduledoc """
  State of an execution
  """

  alias Wanda.Execution.{Fact, Target}

  defstruct [
    :execution_id,
    :group_id,
    targets: [],
    gathered_facts: %{}
  ]

  @type t :: %__MODULE__{
          execution_id: String.t(),
          group_id: String.t(),
          targets: [Target.t()],
          gathered_facts: map()
        }
end

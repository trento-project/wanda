defmodule Wanda.Execution.Target do
  @moduledoc """
  Execution targets.
  """

  defstruct [
    :agent_id,
    checks: []
  ]

  @type t :: %__MODULE__{
          agent_id: String.t(),
          checks: [String.t()]
        }
end

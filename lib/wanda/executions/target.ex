defmodule Wanda.Executions.Target do
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

  @spec get_checks_from_targets([t()]) :: [String.t()]
  def get_checks_from_targets(targets) do
    targets
    |> Enum.flat_map(& &1.checks)
    |> Enum.uniq()
  end
end

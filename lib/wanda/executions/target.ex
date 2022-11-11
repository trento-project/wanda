defmodule Wanda.Executions.Target do
  @moduledoc """
  Execution targets.
  """

  alias Wanda.Executions.Target

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

  def from_list(map_list) do
    Enum.map(map_list, fn %{agent_id: agent_id, checks: checks} ->
      %Target{agent_id: agent_id, checks: checks}
    end)
  end
end

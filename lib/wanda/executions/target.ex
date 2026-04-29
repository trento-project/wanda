defmodule Wanda.Executions.Target do
  @moduledoc """
  Execution targets.
  """

  defstruct [
    :agent_id,
    checks: [],
    host_data: %{}
  ]

  @type t :: %__MODULE__{
          agent_id: String.t(),
          checks: [String.t()],
          host_data: %{String.t() => term()}
        }

  @spec get_checks_from_targets([t()]) :: [String.t()]
  def get_checks_from_targets(targets) do
    targets
    |> Enum.flat_map(& &1.checks)
    |> Enum.uniq()
  end

  def map_targets(map_list) do
    map_list
    |> Enum.uniq_by(& &1.agent_id)
    |> Enum.map(fn %{agent_id: agent_id, checks: checks} = item ->
      %__MODULE__{
        agent_id: agent_id,
        checks: checks,
        host_data: Map.get(item, :host_data, %{})
      }
    end)
  end
end

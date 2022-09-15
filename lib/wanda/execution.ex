defmodule Wanda.Execution do
  @moduledoc """
  Execution API.
  """

  @behaviour Wanda.Execution.Behaviour

  alias Wanda.Catalog

  alias Wanda.Execution.{Server, Supervisor}

  @impl true
  def start_execution(execution_id, group_id, targets, config \\ []) do
    checks =
      targets
      |> Enum.map(& &1.check)
      |> Enum.uniq()
      |> Enum.map(&Catalog.get_check/1)

    DynamicSupervisor.start_child(
      Supervisor,
      {Server,
       execution_id: execution_id,
       group_id: group_id,
       targets: targets,
       checks: checks,
       config: config}
    )
  end

  @impl true
  defdelegate receive_facts(execution_id, agent_id, facts), to: Wanda.Execution.Server
end

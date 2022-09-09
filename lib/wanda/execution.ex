defmodule Wanda.Execution do
  @moduledoc """
  Execution API.
  """

  @behaviour Wanda.Execution.Behaviour

  alias Wanda.Execution.{Server, Supervisor}

  @impl true
  def start_execution(execution_id, group_id, targets, config \\ []) do
    DynamicSupervisor.start_child(
      Supervisor,
      {Server, execution_id: execution_id, group_id: group_id, targets: targets, config: config}
    )
  end

  @impl true
  defdelegate receive_facts(execution_id, agent_id, facts), to: Wanda.Execution.Server
end

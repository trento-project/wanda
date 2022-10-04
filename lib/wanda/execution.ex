defmodule Wanda.Execution do
  @moduledoc """
  Execution API.
  """

  @behaviour Wanda.Execution.Behaviour

  alias Wanda.Catalog

  alias Wanda.Execution.{Server, Supervisor}

  @impl true
  def start_execution(execution_id, group_id, targets, env, config \\ []) do
    checks =
      targets
      |> Enum.map(& &1.checks)
      |> Enum.uniq()
      |> Enum.map(&Catalog.get_check/1)

    case DynamicSupervisor.start_child(
           Supervisor,
           {Server,
            execution_id: execution_id,
            group_id: group_id,
            targets: targets,
            checks: checks,
            env: env,
            config: config}
         ) do
      {:ok, _} ->
        :ok

      {:error, _} = error ->
        error
    end
  end

  @impl true
  defdelegate receive_facts(execution_id, agent_id, facts), to: Wanda.Execution.Server
end

defmodule Wanda.Execution do
  @moduledoc """
  Execution API.
  """

  @behaviour Wanda.Execution.Behaviour

  alias Wanda.Catalog

  alias Wanda.Execution.{Server, Supervisor, Target}

  require Logger

  @impl true
  def start_execution(execution_id, group_id, targets, env, config \\ []) do
    checks =
      targets
      |> Target.get_checks_from_targets()
      |> Catalog.get_checks()

    maybe_start_execution(execution_id, group_id, targets, checks, env, config)
  end

  @impl true
  defdelegate receive_facts(execution_id, agent_id, facts), to: Server

  defp maybe_start_execution(_, _, _, [], _, _), do: {:error, :no_checks_selected}

  defp maybe_start_execution(execution_id, group_id, targets, checks, env, config) do
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
end

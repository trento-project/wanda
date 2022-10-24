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
    with false <- execution_for_group_id_already_running(group_id),
         {:ok, _} <-
           DynamicSupervisor.start_child(
             Supervisor,
             {Server,
              execution_id: execution_id,
              group_id: group_id,
              targets: targets,
              checks: checks,
              env: env,
              config: config}
           ) do
      :ok
    else
      true ->
        {:error, :group_already_running}

      {:error, _} = error ->
        error
    end
  end

  defp execution_for_group_id_already_running(group_id) do
    :global.registered_names()
    |> Enum.flat_map(fn entry ->
      case entry do
        {Server, execution_id} -> [{Server, execution_id}]
        _ -> []
      end
    end)
    |> Enum.any?(fn name ->
      %{group_id: g} =
        name
        |> :global.whereis_name()
        |> :sys.get_state()

      g == group_id
    end)
  end
end

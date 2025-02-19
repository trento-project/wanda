defmodule Wanda.Policy do
  @moduledoc """
  Handles integration events.
  """

  alias Trento.Checks.V1.{
    ExecutionRequested,
    FactsGathered
  }

  alias Trento.Operations.V1.OperationRequested

  alias Wanda.Messaging.Mapper

  alias Wanda.Operations.Catalog.Registry

  require Logger

  @spec handle_event(ExecutionRequested.t() | FactsGathered.t()) :: :ok | {:error, any}
  def handle_event(event) do
    Logger.debug("Handling event #{inspect(event)}")

    handle(event)
  end

  defp handle(%ExecutionRequested{} = message) do
    %{
      execution_id: execution_id,
      group_id: group_id,
      targets: targets,
      env: env,
      target_type: target_type
    } = Mapper.from_execution_requested(message)

    execution_server_impl().start_execution(
      execution_id,
      group_id,
      targets,
      target_type,
      env
    )
  end

  defp handle(%FactsGathered{} = message) do
    %{
      execution_id: execution_id,
      group_id: group_id,
      agent_id: agent_id,
      facts_gathered: facts_gathered
    } = Mapper.from_facts_gathererd(message)

    execution_server_impl().receive_facts(
      execution_id,
      group_id,
      agent_id,
      facts_gathered
    )
  end

  defp handle(%OperationRequested{} = message) do
    %{
      operation_id: operation_id,
      group_id: group_id,
      operation_type: operation_type,
      targets: targets
    } = Mapper.from_operation_requested(message)

    with {:ok, operation} <- Registry.get_operation(operation_type),
         :ok <-
           operation_server_impl().start_operation(
             operation_id,
             group_id,
             operation,
             targets
           ) do
      :ok
    else
      {:error, error} ->
        Logger.error("Invalid operation request: #{error}")

        {:error, error}
    end
  end

  defp execution_server_impl,
    do: Application.fetch_env!(:wanda, Wanda.Policy)[:execution_server_impl]

  defp operation_server_impl,
    do: Application.fetch_env!(:wanda, Wanda.Policy)[:operation_server_impl]
end

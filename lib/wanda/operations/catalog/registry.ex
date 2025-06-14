defmodule Wanda.Operations.Catalog.Registry do
  @moduledoc """
  Operations registry where are available operations are listed
  """

  alias Wanda.Operations.Catalog.Operation

  alias Wanda.Operations.Catalog.{
    ClusterMaintenanceChangeV1,
    PacemakerDisableV1,
    PacemakerEnableV1,
    SapInstanceStartV1,
    SapInstanceStopV1,
    SaptuneApplySolutionV1,
    SaptuneChangeSolutionV1
  }

  @registry %{
    "clustermaintenancechange@v1" => ClusterMaintenanceChangeV1.operation(),
    "pacemakerdisable@v1" => PacemakerDisableV1.operation(),
    "pacemakerenable@v1" => PacemakerEnableV1.operation(),
    "sapinstancestart@v1" => SapInstanceStartV1.operation(),
    "sapinstancestop@v1" => SapInstanceStopV1.operation(),
    "saptuneapplysolution@v1" => SaptuneApplySolutionV1.operation(),
    "saptunechangesolution@v1" => SaptuneChangeSolutionV1.operation()
  }

  @doc """
  Get all operations
  """
  @spec get_operations() :: [Operation.t()]
  def get_operations do
    Map.values(registry())
  end

  @doc """
  Get an operation by id
  """
  @spec get_operation(String.t()) :: {:ok, Operation.t()} | {:error, :operation_not_found}
  def get_operation(id) do
    case Map.get(registry(), id) do
      nil -> {:error, :operation_not_found}
      operation -> {:ok, operation}
    end
  end

  @doc """
  Get an operation by id, erroring out if the entry doesn't exist
  """
  @spec get_operation!(String.t()) :: Operation.t()
  def get_operation!(id) do
    Map.fetch!(registry(), id)
  end

  defp registry do
    Application.get_env(:wanda, :operations_registry, @registry)
  end
end

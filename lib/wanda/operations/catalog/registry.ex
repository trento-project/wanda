defmodule Wanda.Operations.Catalog.Registry do
  @moduledoc """
  Operations registry where are available operations are listed
  """

  alias Wanda.Operations.Catalog.Operation

  alias Wanda.Operations.Catalog.SaptuneApplySolutionV1

  @registry %{
    "saptuneapplysolution@v1" => SaptuneApplySolutionV1.operation()
  }

  @doc """
  Get an operation by id
  """
  @spec get_operation(String.t()) :: {:ok, Operation.t()} | {:error, :operation_not_found}
  def get_operation(id) do
    case Map.get(@registry, id) do
      nil -> {:error, :operation_not_found}
      operation -> {:ok, operation}
    end
  end
end

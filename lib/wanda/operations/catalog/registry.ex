defmodule Wanda.Operations.Catalog.Registry do
  @moduledoc """
  Operations registry where are available operations are listed
  """

  alias Wanda.Operations.Catalog.{Operation, Step}

  @saptuneapplysolution_v1 %Operation{
    id: "saptuneapplysolution@v1",
    name: "Apply saptune solution",
    description: """
    This solution applies a saptune solution in the targets.
    """,
    required_args: ["solution"],
    steps: [
      %Step{
        name: "Apply solution",
        operator: "saptuneapplysolution@v1",
        predicate: "*"
      }
    ]
  }

  @registry %{
    "saptuneapplysolution@v1" => @saptuneapplysolution_v1
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

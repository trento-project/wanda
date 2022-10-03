defmodule Wanda.Results do
  @moduledoc """
  This module exposes functionalities to interact with the historycal log of ExecutionResults.
  """

  alias Wanda.Execution.Result
  alias Wanda.Results.ExecutionResult

  import Ecto.Query

  @doc """
  Saves a result to the database.
  """
  @spec save_result(Result.t()) :: ExecutionResult.t()
  def save_result(
        %Result{
          execution_id: execution_id,
          group_id: group_id
        } = result
      ) do
    %ExecutionResult{
      execution_id: execution_id,
      group_id: group_id,
      payload: result
    }
    |> Wanda.Repo.insert!()
  end

  @doc """
  Gets execution results from the database.
  """
  @spec list_execution_results(map()) :: [ExecutionResult.t()]
  def list_execution_results(params) do
    page = Map.get(params, :page, 1)
    items_per_page = Map.get(params, :items_per_page, 10)
    group_id = Map.get(params, :group_id)

    offset = (page - 1) * items_per_page

    from(e in ExecutionResult)
    |> maybe_filter_by_group_id(group_id)
    |> limit([_], ^items_per_page)
    |> offset([_], ^offset)
    |> Wanda.Repo.all()
  end

  @doc """
  Counts execution results in the database.
  """
  @spec count_execution_results(map()) :: non_neg_integer()
  def count_execution_results(params) do
    group_id = Map.get(params, :group_id)

    from(e in ExecutionResult)
    |> maybe_filter_by_group_id(group_id)
    |> select([e], count())
    |> Wanda.Repo.one()
  end

  @spec maybe_filter_by_group_id(Ecto.Query.t(), String.t()) :: Ecto.Query.t()
  defp maybe_filter_by_group_id(query, nil), do: query

  defp maybe_filter_by_group_id(query, group_id),
    do: from(e in query, where: [group_id: ^group_id])
end

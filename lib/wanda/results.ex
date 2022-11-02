defmodule Wanda.Results do
  @moduledoc """
  This module exposes functionalities to interact with the historycal log of ExecutionResults.
  """

  alias Wanda.Repo

  alias Wanda.Execution.{Result, Target}
  alias Wanda.Results.ExecutionResult

  import Ecto.Query

  @doc """
  Create a new execution.
  """
  @spec create_execution_result!(String.t(), String.t(), [Target.t()]) :: ExecutionResult.t()
  def create_execution_result!(execution_id, group_id, targets) do
    %ExecutionResult{}
    |> ExecutionResult.changeset(%{
      execution_id: execution_id,
      group_id: group_id,
      status: :running,
      targets: Enum.map(targets, &Map.from_struct/1)
    })
    |> Repo.insert!()
  end

  @doc """
  Get a result by execution_id.
  """
  @spec get_execution_result!(String.t()) :: ExecutionResult.t()
  def get_execution_result!(execution_id) do
    Repo.get!(ExecutionResult, execution_id)
  end

  @doc """
  Get a paginated list of results.

  Can be filtered by group_id.
  """
  @spec list_execution_results(map()) :: [ExecutionResult.t()]
  def list_execution_results(params \\ %{}) do
    page = Map.get(params, :page, 1)
    items_per_page = Map.get(params, :items_per_page, 10)
    group_id = Map.get(params, :group_id)

    offset = (page - 1) * items_per_page

    from(e in ExecutionResult)
    |> maybe_filter_by_group_id(group_id)
    |> limit([_], ^items_per_page)
    |> offset([_], ^offset)
    |> Repo.all()
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
    |> Repo.one()
  end

  @doc """
  Marks a previously started execution as completed
  """
  @spec complete_execution_result!(String.t(), Result.t()) ::
          ExecutionResult.t()
  def complete_execution_result!(execution_id, %Result{} = result) do
    ExecutionResult
    |> Repo.get!(execution_id)
    |> ExecutionResult.changeset(%{
      payload: result,
      status: :completed,
      completed_at: DateTime.utc_now()
    })
    |> Repo.update!()
  end

  @spec maybe_filter_by_group_id(Ecto.Query.t(), String.t()) :: Ecto.Query.t()
  defp maybe_filter_by_group_id(query, nil), do: query

  defp maybe_filter_by_group_id(query, group_id),
    do: from(e in query, where: [group_id: ^group_id])
end

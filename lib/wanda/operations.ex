defmodule Wanda.Operations do
  @moduledoc """
  Operations are combined actions dispatched to different agents in order to apply
  persistent changes on them.
  """

  import Ecto.Query

  alias Wanda.Repo

  alias Wanda.Operations.{
    Operation,
    OperationTarget,
    StepReport
  }

  require Wanda.Operations.Enums.Result, as: Result
  require Wanda.Operations.Enums.Status, as: Status

  @doc """
  Create a new operarion.

  If the operation already exists, it will be returned.
  """
  @spec create_operation!(String.t(), String.t(), [OperationTarget.t()]) :: Operation.t()
  def create_operation!(operation_id, group_id, targets) do
    %Operation{}
    |> Operation.changeset(%{
      operation_id: operation_id,
      group_id: group_id,
      status: Status.running(),
      result: Result.not_executed(),
      targets: Enum.map(targets, &Map.from_struct/1)
    })
    |> Repo.insert!(on_conflict: :nothing)
  end

  @doc """
  Get an operation by operation_id.
  """
  @spec get_operation!(String.t()) :: Operation.t()
  def get_operation!(operation_id) do
    Repo.get!(Operation, operation_id)
  end

  @doc """
  Get a paginated list of operations.

  Can be filtered by group_id.
  """
  @spec list_operations(map()) :: [Operation.t()]
  def list_operations(params \\ %{}) do
    page = Map.get(params, :page, 1)
    items_per_page = Map.get(params, :items_per_page, 10)
    group_id = Map.get(params, :group_id)

    offset = (page - 1) * items_per_page

    from(e in Operation)
    |> maybe_filter_by_group_id(group_id)
    |> limit([_], ^items_per_page)
    |> offset([_], ^offset)
    |> order_by(desc: :started_at)
    |> Repo.all()
  end

  @doc """
  Update agent_reports of an operation
  """
  @spec update_agent_reports!(String.t(), [StepReport.t()]) ::
          Operation.t()
  def update_agent_reports!(operation_id, agent_reports) do
    Operation
    |> Repo.get!(operation_id)
    |> Operation.changeset(%{
      agent_reports: agent_reports
    })
    |> Repo.update!()
  end

  @doc """
  Marks a previously started operation as completed
  """
  @spec complete_operation!(String.t(), Result.t()) :: Operation.t()
  def complete_operation!(operation_id, result) do
    Operation
    |> Repo.get!(operation_id)
    |> Operation.changeset(%{
      result: result,
      status: Status.completed(),
      completed_at: DateTime.utc_now()
    })
    |> Repo.update!()
  end

  @spec maybe_filter_by_group_id(Ecto.Query.t(), String.t()) :: Ecto.Query.t()
  defp maybe_filter_by_group_id(query, nil), do: query

  defp maybe_filter_by_group_id(query, group_id),
    do: from(e in query, where: [group_id: ^group_id])
end

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

  alias Wanda.Operations.Catalog.{Registry, Step}

  require Wanda.Operations.Enums.Result, as: Result
  require Wanda.Operations.Enums.Status, as: Status

  @doc """
  Create a new operarion.

  If the operation already exists, it will be returned.
  """
  @spec create_operation!(String.t(), String.t(), String.t(), [OperationTarget.t()]) ::
          Operation.t()
  def create_operation!(operation_id, group_id, catalog_operation_id, targets) do
    %Operation{}
    |> Operation.changeset(%{
      operation_id: operation_id,
      group_id: group_id,
      catalog_operation_id: catalog_operation_id,
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
  Enrich operation adding catalog_operation field
  """
  @spec enrich_operation!(Operation.t()) :: Operation.t()
  def enrich_operation!(%Operation{catalog_operation_id: catalog_operation_id} = operation) do
    catalog_operation = Registry.get_operation!(catalog_operation_id)

    %Operation{operation | catalog_operation: catalog_operation}
  end

  @doc """
  Compute if the operation was aborted using the started_at time and current utc time.
  This function complements the operation gen servers that were abruptly finished without
  setting the new status
  """
  @spec compute_aborted(Operation.t(), Calendar.datetime()) :: Operation.t()
  def compute_aborted(
        %Operation{
          status: Status.running(),
          started_at: started_at,
          catalog_operation: %{steps: steps}
        } = operation,
        utc_now
      ) do
    total_timeout =
      Enum.reduce(steps, 0, fn %Step{timeout: timeout}, acc ->
        acc + timeout
      end)

    timed_out? = DateTime.before?(DateTime.add(started_at, total_timeout, :millisecond), utc_now)

    if timed_out? do
      %Operation{operation | status: Status.aborted()}
    else
      operation
    end
  end

  def compute_aborted(operation, _), do: operation

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

  @doc """
  Marks a previously started operation as aborted
  """
  @spec abort_operation!(String.t()) :: Operation.t()
  def abort_operation!(operation_id) do
    Operation
    |> Repo.get!(operation_id)
    |> Operation.changeset(%{
      status: Status.aborted()
    })
    |> Repo.update!()
  end

  @spec maybe_filter_by_group_id(Ecto.Query.t(), String.t()) :: Ecto.Query.t()
  defp maybe_filter_by_group_id(query, nil), do: query

  defp maybe_filter_by_group_id(query, group_id),
    do: from(e in query, where: [group_id: ^group_id])
end

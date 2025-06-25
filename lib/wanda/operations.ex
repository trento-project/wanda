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

  alias Wanda.Operations.Catalog.Operation, as: CatalogOperation
  alias Wanda.Operations.Catalog.Registry

  require Wanda.Operations.Enums.Result, as: Result
  require Wanda.Operations.Enums.Status, as: Status

  @doc """
  Create a new operarion.

  If the operation already exists, it will be returned.
  """
  @spec create_operation!(String.t(), String.t(), String.t(), [OperationTarget.t()]) ::
          Operation.t()
  def create_operation!(operation_id, group_id, catalog_operation_id, targets) do
    total_timeout =
      catalog_operation_id
      |> Registry.get_operation!()
      |> CatalogOperation.total_timeout()

    timeout_at = DateTime.add(date_service().utc_now(), total_timeout, :millisecond)

    %Operation{}
    |> Operation.changeset(%{
      operation_id: operation_id,
      group_id: group_id,
      catalog_operation_id: catalog_operation_id,
      status: Status.running(),
      result: Result.not_executed(),
      targets: Enum.map(targets, &Map.from_struct/1),
      timeout_at: timeout_at
    })
    |> Repo.insert!(on_conflict: :nothing)
  end

  @doc """
  Get an operation by operation_id.
  """
  @spec get_operation!(String.t()) :: Operation.t()
  def get_operation!(operation_id) do
    utc_now = date_service().utc_now()

    from(e in Operation)
    |> compute_aborted(utc_now)
    |> Repo.get!(operation_id)
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
  Get a paginated list of operations.

  Can be filtered by group_id.
  """
  @spec list_operations(map()) :: [Operation.t()]
  def list_operations(params \\ %{}) do
    page = Map.get(params, :page, 1)
    items_per_page = Map.get(params, :items_per_page, 10)
    group_id = Map.get(params, :group_id)
    status = Map.get(params, :status)

    offset = (page - 1) * items_per_page

    utc_now = date_service().utc_now()

    from(e in Operation)
    |> compute_aborted(utc_now)
    |> maybe_filter_by_group_id(group_id)
    |> maybe_filter_by_status(status, utc_now)
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
      completed_at: date_service().utc_now()
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

  @spec compute_aborted(Ecto.Query.t(), DateTime.t()) :: Ecto.Query.t()
  defp compute_aborted(query, utc_now) do
    select(query, [e], %{
      e
      | status:
          type(
            fragment(
              "CASE WHEN status = 'running' and ? > timeout_at THEN 'aborted' ELSE ? END",
              ^utc_now,
              e.status
            ),
            e.status
          )
    })
  end

  @spec maybe_filter_by_group_id(Ecto.Query.t(), String.t()) :: Ecto.Query.t()
  defp maybe_filter_by_group_id(query, nil), do: query

  defp maybe_filter_by_group_id(query, group_id),
    do: from(e in query, where: [group_id: ^group_id])

  @spec maybe_filter_by_status(Ecto.Query.t(), String.t(), DateTime.t()) :: Ecto.Query.t()
  defp maybe_filter_by_status(query, nil, _), do: query

  defp maybe_filter_by_status(query, Status.running(), utc_now) do
    query
    |> where(status: ^Status.running())
    |> where([e], e.timeout_at > ^utc_now)
  end

  defp maybe_filter_by_status(query, Status.aborted(), utc_now) do
    where(
      query,
      [e],
      e.status == ^Status.aborted() or (e.timeout_at < ^utc_now and e.status == ^Status.running())
    )
  end

  defp maybe_filter_by_status(query, status, _),
    do: from(e in query, where: [status: ^status])

  defp date_service,
    do: Application.fetch_env!(:wanda, :date_service)
end

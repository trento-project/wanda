defmodule Wanda.Operations do
  @moduledoc """
  Operations are combined actions dispatched to different agents in order to apply
  persistent changes on them.
  """

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
end

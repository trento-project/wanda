defmodule Wanda.Results.ExecutionResult do
  @moduledoc """
  Represents a storable ExecutionResult, available after check evaluation
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Wanda.Execution.Result

  @type t :: %__MODULE__{}

  @derive {Jason.Encoder, [except: [:__meta__]]}
  @primary_key false
  schema "execution_results" do
    field :execution_id, Ecto.UUID, primary_key: true
    field :group_id, Ecto.UUID
    field :payload, :map, default: %{}
    field :status, Ecto.Enum, values: [:running, :completed]

    embeds_many :targets, Target do
      field :agent_id, Ecto.UUID
      field :checks, {:array, :string}
    end

    timestamps(type: :utc_datetime_usec)

    field :completed_at, :utc_datetime_usec
  end

  @spec changeset(t() | Ecto.Changeset.t(), map) :: Ecto.Changeset.t()
  def changeset(execution, params) do
    execution
    |> cast(params, __MODULE__.__schema__(:fields) -- [:targets])
    |> cast_embed(:targets, with: &target_changeset/2)
  end

  @spec complete_changeset(t(), Result.t()) :: Ecto.Changeset.t()
  def complete_changeset(execution, %Result{} = result) do
    changeset(execution, %{
      payload: result,
      status: :completed,
      completed_at: DateTime.utc_now()
    })
  end

  defp target_changeset(target, params) do
    cast(target, params, [:agent_id, :checks])
  end
end

defmodule Wanda.Results.ExecutionResult do
  @moduledoc """
  Represents a storable ExecutionResult, available after check evaluation
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @fields ~w(execution_id group_id payload status)a
  @target_fields ~w(agent_id checks)a

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

    timestamps(type: :utc_datetime_usec, inserted_at: :started_at, updated_at: false)
    field :completed_at, :utc_datetime_usec
  end

  @spec changeset(t() | Ecto.Changeset.t(), map) :: Ecto.Changeset.t()
  def changeset(execution, params) do
    execution
    |> cast(params, @fields)
    |> cast_embed(:targets, with: &target_changeset/2)
  end

  defp target_changeset(target, params) do
    cast(target, params, @target_fields)
  end
end

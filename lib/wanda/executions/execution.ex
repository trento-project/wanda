defmodule Wanda.Executions.Execution do
  @moduledoc """
  Schema of a persisted execution.
  """

  use Ecto.Schema

  import Ecto.Changeset

  require Wanda.Expectations.Enums.Status, as: Status

  @type t :: %__MODULE__{}

  @fields ~w(execution_id group_id result status started_at completed_at)a
  @target_fields ~w(agent_id checks)a

  @derive {Jason.Encoder, [except: [:__meta__]]}
  @primary_key false
  schema "executions" do
    field :execution_id, Ecto.UUID, primary_key: true
    field :group_id, Ecto.UUID
    field :result, :map, default: %{}
    field :status, Ecto.Enum, values: Status.values()

    embeds_many :targets, Target do
      @derive {Jason.Encoder, [except: [:id]]}

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

defmodule Wanda.Results.ExecutionResult do
  @moduledoc """
  Represents a storable ExecutionResult, available after check evaluation
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @derive {Jason.Encoder, [except: [:__meta__]]}
  @primary_key false
  schema "execution_results" do
    field :execution_id, Ecto.UUID, primary_key: true
    field :group_id, Ecto.UUID
    field :payload, :map, default: %{}

    field :status, Ecto.Enum, values: [:running, :completed], default: :running

    timestamps(type: :utc_datetime_usec)

    field :completed_at, :utc_datetime_usec
  end

  @spec changeset(t() | Ecto.Changeset.t(), map) :: Ecto.Changeset.t()
  def changeset(execution, attrs) do
    cast(execution, attrs, __MODULE__.__schema__(:fields))
  end
end

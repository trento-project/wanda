defmodule Wanda.Executions.Execution do
  @moduledoc """
  Schema of a persisted execution.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @fields ~w(execution_id group_id result status started_at completed_at)a

  @derive {Jason.Encoder, [except: [:__meta__]]}
  @primary_key false
  schema "executions" do
    field :execution_id, Ecto.UUID, primary_key: true
    field :group_id, Ecto.UUID
    field :result, :map, default: %{}
    field :status, Ecto.Enum, values: [:running, :completed]

    embeds_many :targets, Wanda.Executions.Execution.Target

    timestamps(type: :utc_datetime_usec, inserted_at: :started_at, updated_at: false)
    field :completed_at, :utc_datetime_usec
  end

  @spec changeset(t() | Ecto.Changeset.t(), map) :: Ecto.Changeset.t()
  def changeset(execution, params) do
    execution
    |> cast(params, @fields)
    |> cast_embed(:targets)
  end
end

defmodule Wanda.Executions.Execution.Target do
  @moduledoc """
  Schema of target within an execution.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @fields ~w(agent_id checks)a

  @derive {Jason.Encoder, [except: [:id]]}
  embedded_schema do
    field :agent_id, Ecto.UUID
    field :checks, {:array, :string}
  end

  def changeset(target, params) do
    cast(target, params, @fields)
  end
end

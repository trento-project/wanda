defmodule Wanda.Operations.Operation do
  @moduledoc """
  Schema of a persisted operation.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Wanda.Operations.Catalog.Registry

  require Wanda.Operations.Enums.Result, as: Result
  require Wanda.Operations.Enums.Status, as: Status

  @type t :: %__MODULE__{}

  @fields ~w(operation_id group_id result status agent_reports catalog_operation_id started_at updated_at completed_at)a
  @target_fields ~w(agent_id arguments)a

  @required_fields ~w(operation_id group_id result status)a
  @targets_required_fields ~w(agent_id)a

  @derive {Jason.Encoder, [except: [:__meta__]]}
  @primary_key false
  schema "operations" do
    field :operation_id, Ecto.UUID, primary_key: true
    field :group_id, Ecto.UUID
    field :result, Ecto.Enum, values: Result.values()
    field :status, Ecto.Enum, values: Status.values()

    embeds_many :targets, Target, primary_key: false do
      @derive Jason.Encoder

      field :agent_id, Ecto.UUID, primary_key: true
      field :arguments, :map
    end

    field :agent_reports, Wanda.Support.Ecto.Json

    field :catalog_operation_id, :string
    field :catalog_operation, :map, virtual: true

    field :completed_at, :utc_datetime_usec
    timestamps(type: :utc_datetime_usec, inserted_at: :started_at)
  end

  @spec changeset(t() | Ecto.Changeset.t(), map) :: Ecto.Changeset.t()
  def changeset(operation, params) do
    operation
    |> cast(params, @fields)
    |> cast_embed(:targets, with: &target_changeset/2, required: true)
    |> validate_required(@required_fields)
    |> validate_change(:catalog_operation_id, &validate_catalog_operation_id/2)
  end

  defp target_changeset(target, params) do
    target
    |> cast(params, @target_fields)
    |> validate_required(@targets_required_fields)
  end

  defp validate_catalog_operation_id(:catalog_operation_id, catalog_operation_id) do
    case Registry.get_operation(catalog_operation_id) do
      {:error, :operation_not_found} ->
        [catalog_operation_id: "not found"]

      _ ->
        []
    end
  end
end

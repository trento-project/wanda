defmodule Wanda.Repo.Migrations.AddOperation do
  use Ecto.Migration

  def change do
    create table(:operations, primary_key: false) do
      add :operation_id, :uuid, primary_key: true
      add :group_id, :uuid, null: false
      add :result, :string, null: false
      add :status, :string, null: false
      add :targets, :map, null: false, default: "[]"
      add :agent_reports, :map, null: false, default: "[]"

      timestamps(type: :utc_datetime_usec, inserted_at: :started_at, updated_at: false)
      add :completed_at, :utc_datetime_usec
    end

    create index(:operations, [:group_id])
    create unique_index(:operations, [:operation_id, :group_id])
  end
end

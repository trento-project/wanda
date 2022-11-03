defmodule Wanda.Repo.Migrations.AddExecution do
  use Ecto.Migration

  def change do
    create table(:executions, primary_key: false) do
      add :execution_id, :uuid, primary_key: true
      add :group_id, :uuid, null: false
      add :result, :map, null: false
      add :status, :string, null: false
      add :targets, :map, null: false, default: "[]"
      timestamps(type: :utc_datetime_usec, inserted_at: :started_at, updated_at: false)
      add :completed_at, :utc_datetime_usec
    end

    create index(:executions, [:group_id])
    create unique_index(:executions, [:execution_id, :group_id])
  end
end

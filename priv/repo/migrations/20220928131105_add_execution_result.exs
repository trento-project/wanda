defmodule Wanda.Repo.Migrations.AddExecutionResult do
  use Ecto.Migration

  def change do
    create table(:execution_results, primary_key: false) do
      add :execution_id, :uuid, primary_key: true
      add :group_id, :uuid, null: false
      add :payload, :map, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:execution_results, [:group_id])
    create unique_index(:execution_results, [:execution_id, :group_id])
  end
end

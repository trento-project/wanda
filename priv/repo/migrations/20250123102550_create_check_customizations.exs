defmodule Wanda.Repo.Migrations.CreateCheckCustomizations do
  use Ecto.Migration

  def change do
    create table(:check_customizations, primary_key: false) do
      add :check_id, :string, null: false, primary_key: true
      add :group_id, :uuid, null: false, primary_key: true
      add :custom_values, :jsonb, null: false, default: "[]"

      timestamps()
    end
  end
end

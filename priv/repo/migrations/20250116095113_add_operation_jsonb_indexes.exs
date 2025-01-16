defmodule Wanda.Repo.Migrations.AddOperationJsonbIndexes do
  use Ecto.Migration

  def change do
    create index(:operations, ["targets jsonb_path_ops"], using: "GIN")
    create index(:operations, ["agent_reports jsonb_path_ops"], using: "GIN")
  end
end

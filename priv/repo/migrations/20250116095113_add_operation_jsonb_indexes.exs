defmodule Wanda.Repo.Migrations.AddOperationJsonbIndexes do
  use Ecto.Migration

  def up do
    execute("CREATE INDEX operation_targets ON operations USING GIN(targets)")
    execute("CREATE INDEX operation_agent_reports ON operations USING GIN(agent_reports)")
  end

  def down do
    execute("DROP INDEX operation_targets")
    execute("DROP INDEX operation_agent_reports")
  end
end

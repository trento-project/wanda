defmodule Wanda.Operations.Catalog.DatabaseStopV1 do
  @moduledoc false

  use Wanda.Operations.Catalog.Operation,
    operation: %Wanda.Operations.Catalog.Operation{
      id: "databasestop@v1",
      name: "Stop HANA database",
      description: """
      This operation stops a HANA database. The database can be a standalone database
      or a database configured using system replication.
      The stopping order is from system replication tier 3 to 1.
      If system replication is not configured it simply stops the given system.

      Arguments:
        instance_number (string): Instance number to stop the database
        system_replication_tier (number): Instance system replication tier number.
          Null if it does not have system replication
        timeout (number): Timeout in seconds to wait until the database is stopped
      """,
      required_args: ["instance_number", "system_replication_tier"],
      steps: [
        %Wanda.Operations.Catalog.Step{
          name: "Stop HANA database tier 3",
          operator: "sapsystemstop@v1",
          predicate: "system_replication_tier == 3",
          # 12 hours
          timeout: 12 * 60 * 60 * 1_000
        },
        %Wanda.Operations.Catalog.Step{
          name: "Stop HANA database tier 2",
          operator: "sapsystemstop@v1",
          predicate: "system_replication_tier == 2",
          timeout: 12 * 60 * 60 * 1_000
        },
        %Wanda.Operations.Catalog.Step{
          name: "Stop HANA database tier 1",
          operator: "sapsystemstop@v1",
          predicate: "system_replication_tier == 1 || system_replication_tier == ()",
          timeout: 12 * 60 * 60 * 1_000
        }
      ]
    }
end

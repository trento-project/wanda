defmodule Wanda.Operations.Catalog.DatabaseStartV1 do
  @moduledoc false

  use Wanda.Operations.Catalog.Operation,
    operation: %Wanda.Operations.Catalog.Operation{
      id: "databasestart@v1",
      name: "Start HANA database",
      description: """
      This operation starts a HANA database. The database can be a standalone database
      or a database configured using system replication.
      The starting order is from system replication tier 1 to 3.
      If system replication is not configured it simply starts the given system.

      Arguments:
        instance_number (string): Instance number to start the database
        system_replication_tier (number): Instance system replication tier number.
          Null if it does not have system replication
        timeout (number): Timeout in seconds to wait until the database is started
      """,
      required_args: ["instance_number", "system_replication_tier"],
      steps: [
        %Wanda.Operations.Catalog.Step{
          name: "Start HANA database tier 1",
          operator: "sapsystemstart@v1",
          predicate: "system_replication_tier == 1 || system_replication_tier == ()",
          # 12 hours
          timeout: 12 * 60 * 60 * 1_000
        },
        %Wanda.Operations.Catalog.Step{
          name: "Start HANA database tier 2",
          operator: "sapsystemstart@v1",
          predicate: "system_replication_tier == 2",
          timeout: 12 * 60 * 60 * 1_000
        },
        %Wanda.Operations.Catalog.Step{
          name: "Start HANA database tier 3",
          operator: "sapsystemstart@v1",
          predicate: "system_replication_tier == 3",
          timeout: 12 * 60 * 60 * 1_000
        }
      ]
    }
end

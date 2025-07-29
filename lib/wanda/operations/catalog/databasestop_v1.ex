defmodule Wanda.Operations.Catalog.DatabaseStopV1 do
  @moduledoc false

  use Wanda.Operations.Catalog.Operation,
    operation: %Wanda.Operations.Catalog.Operation{
      id: "databasestop@v1",
      name: "Stop HANA database",
      description: """
      This operation stops a HANA database. If the database is in a system
      replication configuration, it only stops the site where the given target
      belongs to. Other sites are not impacted.

      Arguments:
        instance_number (string): Instance number to stop the database
        timeout (number): Timeout in seconds to wait until the database is stopped
      """,
      required_args: ["instance_number"],
      steps: [
        %Wanda.Operations.Catalog.Step{
          name: "Stop HANA database",
          operator: "sapsystemstop@v1",
          predicate: "*",
          # 12 hours
          timeout: 12 * 60 * 60 * 1_000
        }
      ]
    }
end

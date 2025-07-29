defmodule Wanda.Operations.Catalog.DatabaseStartV1 do
  @moduledoc false

  use Wanda.Operations.Catalog.Operation,
    operation: %Wanda.Operations.Catalog.Operation{
      id: "databasestart@v1",
      name: "Start HANA database",
      description: """
      This operation starts a complete HANA database.

      Arguments:
        instance_number (string): Instance number to start the database
        timeout (number): Timeout in seconds to wait until the database is started
      """,
      required_args: ["instance_number"],
      steps: [
        %Wanda.Operations.Catalog.Step{
          name: "Start HANA database",
          operator: "sapsystemstart@v1",
          predicate: "*",
          # 12 hours
          timeout: 12 * 60 * 60 * 1_000
        }
      ]
    }
end

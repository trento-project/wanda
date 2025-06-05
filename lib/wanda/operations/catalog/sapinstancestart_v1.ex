defmodule Wanda.Operations.Catalog.SapInstanceStartV1 do
  @moduledoc false

  use Wanda.Operations.Catalog.Operation,
    operation: %Wanda.Operations.Catalog.Operation{
      id: "sapinstancestart@v1",
      name: "Start SAP instance",
      description: """
      This operation starts a SAP instance.

      Arguments:
        instance_number (string): Instance number to start the instance
        timeout (number): Timeout in seconds to wait until the instance is started
      """,
      required_args: ["instance_number"],
      steps: [
        %Wanda.Operations.Catalog.Step{
          name: "Start SAP instance",
          operator: "sapinstancestart@v1",
          predicate: "*"
        }
      ]
    }
end

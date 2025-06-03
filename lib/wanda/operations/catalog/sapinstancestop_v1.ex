defmodule Wanda.Operations.Catalog.SapInstanceStopV1 do
  @moduledoc false

  use Wanda.Operations.Catalog.Operation,
    operation: %Wanda.Operations.Catalog.Operation{
      id: "sapinstancestop@v1",
      name: "Stop SAP instance",
      description: """
      This operation stops a SAP instance.

      Arguments:
        instance_number (string): Instance number to stop the instance
        timeout (number): Timeout in seconds to wait until the instance is stopped
      """,
      required_args: ["instance_number"],
      steps: [
        %Wanda.Operations.Catalog.Step{
          name: "Stop SAP instance",
          operator: "sapinstancestop@v1",
          predicate: "*"
        }
      ]
    }
end

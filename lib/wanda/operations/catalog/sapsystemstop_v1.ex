defmodule Wanda.Operations.Catalog.SapSystemStopV1 do
  @moduledoc false

  use Wanda.Operations.Catalog.Operation,
    operation: %Wanda.Operations.Catalog.Operation{
      id: "sapsystemstop@v1",
      name: "Stop SAP system",
      description: """
      This operation stops a complete SAP system.

      Arguments:
        instance_number (string): Instance number to stop the system
        instance_type (string): Instance type to stop. Available values: all|abap|j2ee|scs|enqrep. Default value: all
        timeout (number): Timeout in seconds to wait until the system is stopped
      """,
      required_args: ["instance_number"],
      steps: [
        %Wanda.Operations.Catalog.Step{
          name: "Stop SAP system",
          operator: "sapsystemstop@v1",
          predicate: "*",
          timeout: 60 * 60 * 1_000
        }
      ]
    }
end

defmodule Wanda.Operations.Catalog.SapSystemStartV1 do
  @moduledoc false

  use Wanda.Operations.Catalog.Operation,
    operation: %Wanda.Operations.Catalog.Operation{
      id: "sapsystemstart@v1",
      name: "Start SAP system",
      description: """
      This operation starts a complete SAP system.

      Arguments:
        instance_number (string): Instance number to start the system
        instance_type (string): Instance type to start. Available values: all|abap|j2ee|scs|enqrep. Default value: all
        timeout (number): Timeout in seconds to wait until the system is started
      """,
      required_args: ["instance_number"],
      steps: [
        %Wanda.Operations.Catalog.Step{
          name: "Start SAP system",
          operator: "sapsystemstart@v1",
          predicate: "*"
        }
      ]
    }
end

defmodule Wanda.Operations.Catalog.UnregisterHANASecondaryV1 do
  @moduledoc false

  use Wanda.Operations.Catalog.Operation,
    operation: %Wanda.Operations.Catalog.Operation{
      id: "unregisterhanasecondary@v1",
      name: "Unregister HANA Secondary",
      description: """
      This operation unregisters a HANA secondary from system replication setup.

      In order to unregister a HANA secondary, it must be stopped first and then to finalize unregistration it needs to be started again.

      The operation is meant to run on only one of the HANA secondary nodes so when requesting the operation,
      make sure to sennd only one target.

      Arguments:
        sid (string): The System ID of the HANA secondary to unregister
      """,
      required_args: ["sid"],
      steps: [
        %Wanda.Operations.Catalog.Step{
          name: "Unregister HANA Secondary",
          operator: "unregisterhanasecondary@v1",
          predicate: "*"
        }
      ]
    }
end

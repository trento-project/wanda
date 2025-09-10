defmodule Wanda.Operations.Catalog.HostRebootV1 do
  @moduledoc false

  use Wanda.Operations.Catalog.Operation,
    operation: %Wanda.Operations.Catalog.Operation{
      id: "hostreboot@v1",
      name: "Reboot host",
      description: """
      This operation reboots a specified host.
      It is typically used to recover a host that is unresponsive or to apply updates.
      """,
      required_args: [],
      steps: [
        %Wanda.Operations.Catalog.Step{
          name: "Reboot the host",
          operator: "hostreboot@v1",
          predicate: "*"
        }
      ]
    }
end

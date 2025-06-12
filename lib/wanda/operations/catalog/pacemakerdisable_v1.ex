defmodule Wanda.Operations.Catalog.PacemakerDisableV1 do
  @moduledoc false

  use Wanda.Operations.Catalog.Operation,
    operation: %Wanda.Operations.Catalog.Operation{
      id: "pacemakerdisable@v1",
      name: "Disable Pacemaker",
      description: """
      This operation disables Pacemaker on the specified node.
      Usually nodes that are part of the same pacemaker cluster.

      Arguments: no arguments are required for this operation.
      """,
      steps: [
        %Wanda.Operations.Catalog.Step{
          name: "Disable Pacemaker",
          operator: "pacemakerdisable@v1",
          predicate: "*"
        }
      ]
    }
end

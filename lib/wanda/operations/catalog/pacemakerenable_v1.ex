defmodule Wanda.Operations.Catalog.PacemakerEnableV1 do
  @moduledoc false

  use Wanda.Operations.Catalog.Operation,
    operation: %Wanda.Operations.Catalog.Operation{
      id: "pacemakerenable@v1",
      name: "Enable Pacemaker",
      description: """
      This operation enables Pacemaker on the group of nodes.
      Usually nodes that are part of the same pacemaker cluster.

      Arguments: no arguments are required for this operation.
      """,
      steps: [
        %Wanda.Operations.Catalog.Step{
          name: "Enable Pacemaker",
          operator: "pacemakerenable@v1",
          predicate: "*"
        }
      ]
    }
end

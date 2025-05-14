defmodule Wanda.Operations.Catalog.ClusterMaintenanceChangeV1 do
  @moduledoc false

  use Wanda.Operations.Catalog.Operation,
    operation: %Wanda.Operations.Catalog.Operation{
      id: "clustermaintenancechange@v1",
      name: "Change cluster maintenance state",
      description: """
      This operation changes the cluster, cluster resource or cluster node maintenance state.
      """,
      required_args: ["maintenance", "is_dc"],
      steps: [
        %Wanda.Operations.Catalog.Step{
          name: "Change maintenance state",
          operator: "clustermaintenancechange@v1",
          predicate: "is_dc==true"
        }
      ]
    }
end

defmodule Wanda.Operations.Catalog.ClusterMaintenanceChangeV1 do
  @moduledoc false

  use Wanda.Operations.Catalog.Operation,
    operation: %Wanda.Operations.Catalog.Operation{
      id: "clustermaintenancechange@v1",
      name: "Change cluster maintenance state",
      description: """
      This operation changes the cluster, cluster resource or cluster node maintenance state.

      If neither resource_id nor node_id are given, the whole cluster maintenance state is
      changed.

      Arguments:
        maintenance (boolean): Maintenance state to change the cluster, node or resource
        is_dc (boolean): Whether the target is the designated controller of the cluster
        resource_id (string): The ID of the cluster resource to change the state (this has precedence over node_id)
        node_id (string): The ID of the cluster node to change the state
      """,
      required_args: ["maintenance", "is_dc"],
      steps: [
        %Wanda.Operations.Catalog.Step{
          name: "Change maintenance state",
          operator: "clustermaintenancechange@v1",
          predicate: "is_dc == true"
        }
      ]
    }
end

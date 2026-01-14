defmodule Wanda.Operations.Catalog.ClusterResourceRefreshV1 do
  @moduledoc false

  use Wanda.Operations.Catalog.Operation,
    operation: %Wanda.Operations.Catalog.Operation{
      id: "clusterresourcerefresh@v1",
      name: "Refresh cluster resources",
      description: """
      This operation refreshes cluster resources.

      If neither resource_id nor node_id are given, all the resources in the cluster are refreshed.

      Arguments:
        is_dc (boolean): Whether the target is the designated controller of the cluster
        resource_id (string): The ID of the cluster resource to refresh
        node_id (string): The ID of the cluster node where the resource with resource_id is running. It has to be provided with a resource_id
      """,
      required_args: ["is_dc"],
      steps: [
        %Wanda.Operations.Catalog.Step{
          name: "Refresh cluster resource",
          operator: "clusterresourcerefresh@v1",
          predicate: "is_dc == true"
        }
      ]
    }
end

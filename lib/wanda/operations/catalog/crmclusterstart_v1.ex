defmodule Wanda.Operations.Catalog.CrmClusterStartV1 do
  @moduledoc false

  use Wanda.Operations.Catalog.Operation,
    operation: %Wanda.Operations.Catalog.Operation{
      id: "crmclusterstart@v1",
      name: "Set node online in cluster",
      description: """
      This operation sets a node online in the cluster.
      It is typically used to bring a node back into the cluster after it has been down or
      to initiate the cluster services on a new node.
      """,
      required_args: [],
      steps: [
        %Wanda.Operations.Catalog.Step{
          name: "Set node online in cluster",
          operator: "crmclusterstart@v1",
          predicate: "*"
        }
      ]
    }
end

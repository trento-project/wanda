defmodule Wanda.Operations.Catalog.CrmClusterStartV1 do
  @moduledoc false

  use Wanda.Operations.Catalog.Operation,
    operation: %Wanda.Operations.Catalog.Operation{
      id: "crmclusterstart@v1",
      name: "Start HA cluster on the node",
      description: """
      This operation starts the High Availability (HA) cluster on a specified node.
      It is typically used to bring a node back into the cluster after it has been down or
      to initiate the cluster services on a new node.
      """,
      required_args: [],
      steps: [
        %Wanda.Operations.Catalog.Step{
          name: "Start HA cluster on the node",
          operator: "crmclusterstart@v1",
          predicate: "*"
        }
      ]
    }
end

defmodule Wanda.Operations.Catalog.CrmClusterStopV1 do
  @moduledoc false

  use Wanda.Operations.Catalog.Operation,
    operation: %Wanda.Operations.Catalog.Operation{
      id: "crmclusterstop@v1",
      name: "Stop HA cluster on the node",
      description: """
      This operation stops the High Availability (HA) cluster on a specified node.
      It is typically used to bring a node down from the cluster or to stop the cluster services on a node.
      """,
      required_args: [],
      steps: [
        %Wanda.Operations.Catalog.Step{
          name: "Stop HA cluster on the node",
          operator: "crmclusterstop@v1",
          predicate: "*"
        }
      ]
    }
end

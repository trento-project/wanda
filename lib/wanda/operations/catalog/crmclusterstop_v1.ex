defmodule Wanda.Operations.Catalog.CrmClusterStopV1 do
  @moduledoc false

  use Wanda.Operations.Catalog.Operation,
    operation: %Wanda.Operations.Catalog.Operation{
      id: "crmclusterstop@v1",
      name: "Set node offline in cluster",
      description: """
      This operation sets a node offline in the cluster.
      It is typically used to bring a node down from the cluster or to stop the cluster services on a node.
      """,
      required_args: [],
      steps: [
        %Wanda.Operations.Catalog.Step{
          name: "Set node offline in cluster",
          operator: "crmclusterstop@v1",
          predicate: "*"
        }
      ]
    }
end

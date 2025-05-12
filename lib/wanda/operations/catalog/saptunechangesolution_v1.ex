defmodule Wanda.Operations.Catalog.SaptuneChangeSolutionV1 do
  @moduledoc false

  use Wanda.Operations.Catalog.Operation,
    operation: %Wanda.Operations.Catalog.Operation{
      id: "saptunechangesolution@v1",
      name: "Change saptune solution",
      description: """
      This operation changes a saptune solution in the targets.
      """,
      required_args: ["solution"],
      steps: [
        %Wanda.Operations.Catalog.Step{
          name: "Change solution",
          operator: "saptunechangesolution@v1",
          predicate: "*"
        }
      ]
    }
end

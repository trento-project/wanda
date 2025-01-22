defmodule Wanda.Operations.Catalog.SaptuneApplySolutionV1 do
  @moduledoc false

  use Wanda.Operations.Catalog.Operation,
    operation: %Wanda.Operations.Catalog.Operation{
      id: "saptuneapplysolution@v1",
      name: "Apply saptune solution",
      description: """
      This operation applies a saptune solution in the targets.
      """,
      required_args: ["solution"],
      steps: [
        %Wanda.Operations.Catalog.Step{
          name: "Apply solution",
          operator: "saptuneapplysolution@v1",
          predicate: "*"
        }
      ]
    }
end

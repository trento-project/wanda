defmodule Wanda.Operations.Catalog.SaptuneApplySolutionV1 do
  alias Wanda.Operations.Catalog.{Operation, Step}

  use Operation,
    operation: %Operation{
      id: "saptuneapplysolution@v1",
      name: "Apply saptune solution",
      description: """
      This solution applies a saptune solution in the targets.
      """,
      required_args: ["solution"],
      steps: [
        %Step{
          name: "Apply solution",
          operator: "saptuneapplysolution@v1",
          predicate: "*"
        }
      ]
    }
end

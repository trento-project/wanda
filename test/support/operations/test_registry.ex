defmodule Wanda.Operations.Catalog.TestRegistry do
  @moduledoc false

  def test_registry do
    %{
      "testoperation@v1" => %Wanda.Operations.Catalog.Operation{
        id: "testoperation@v1",
        name: "Test operation",
        description: """
        A test operation.
        """,
        required_args: ["arg"],
        steps: [
          %Wanda.Operations.Catalog.Step{
            name: "First step",
            operator: "test@v1",
            predicate: "*"
          }
        ]
      }
    }
  end
end

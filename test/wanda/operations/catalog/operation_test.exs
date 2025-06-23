defmodule Wanda.Operations.Catalog.OperationTest do
  use ExUnit.Case

  alias Wanda.Operations.Catalog.{Operation, Step}

  test "should return operation total timeout" do
    operation = %Operation{
      steps: [
        %Step{
          timeout: 3_000
        },
        %Step{
          timeout: 7_000
        },
        %Step{
          timeout: 5 * 1_000
        }
      ]
    }

    assert 15_000 == Operation.total_timeout(operation)
  end
end

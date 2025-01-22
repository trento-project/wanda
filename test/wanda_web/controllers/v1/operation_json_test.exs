defmodule WandaWeb.V1.OperationJSONTest do
  use ExUnit.Case, async: true

  import Wanda.Factory

  alias WandaWeb.V1.OperationJSON

  describe "OperationJSON" do
    test "renders index.json" do
      operations = build_list(5, :operation)

      expected_operations =
        Enum.map(operations, fn operation -> Map.drop(operation, [:__meta__, :__struct__]) end)

      assert %{
               items: ^expected_operations,
               total_count: 5
             } =
               OperationJSON.index(%{
                 operations: operations
               })
    end

    test "renders show.json for a running execution" do
      operation = build(:operation)
      expected_operation = Map.drop(operation, [:__meta__, :__struct__])

      assert ^expected_operation = OperationJSON.show(%{operation: operation})
    end
  end
end

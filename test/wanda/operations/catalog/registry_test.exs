defmodule Wanda.Operations.Catalog.RegistryTest do
  use ExUnit.Case

  alias Wanda.Operations.Catalog.{
    Operation,
    Registry
  }

  describe "operations" do
    test "should return all existing operations" do
      Enum.each(Registry.get_operations(), fn op ->
        assert %Operation{} = op
      end)
    end

    test "should return operation by id" do
      assert {:ok, %Operation{id: "saptuneapplysolution@v1"}} =
               Registry.get_operation("saptuneapplysolution@v1")
    end

    test "should return a not found error if operation does not exist" do
      assert {:error, :operation_not_found} =
               Registry.get_operation("somenastyoperation")
    end
  end
end

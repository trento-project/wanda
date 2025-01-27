defmodule Wanda.Operations.Catalog.RegistryTest do
  use ExUnit.Case

  alias Wanda.Operations.Catalog.{
    Operation,
    Registry
  }

  describe "get_operations/0" do
    test "should return all existing operations" do
      Enum.each(Registry.get_operations(), fn op ->
        assert %Operation{} = op
      end)
    end
  end

  describe "get_operation/1" do
    test "should return operation by id" do
      assert {:ok, %Operation{id: "saptuneapplysolution@v1"}} =
               Registry.get_operation("saptuneapplysolution@v1")
    end

    test "should return a not found error if operation does not exist" do
      assert {:error, :operation_not_found} =
               Registry.get_operation("somenastyoperation")
    end
  end

  describe "get_operation!/1" do
    test "should directly return operation by id" do
      assert %Operation{id: "saptuneapplysolution@v1"} =
               Registry.get_operation!("saptuneapplysolution@v1")
    end

    test "should bang if operation does not exist" do
      assert_raise KeyError, fn ->
        Registry.get_operation!("somenastyoperation")
      end
    end
  end
end

defmodule Wanda.CatalogTest do
  use ExUnit.Case

  alias Wanda.Catalog

  alias Wanda.Catalog.{
    Check,
    Condition,
    Expectation,
    Fact,
    Value
  }

  describe "checks catalog" do
    test "should load a check from a yaml file properly" do
      assert %Check{
               id: "expect_check",
               name: "Test check",
               severity: :critical,
               facts: [
                 %Fact{
                   name: "corosync_token_timeout",
                   gatherer: "corosync",
                   argument: "totem.token"
                 }
               ],
               values: [],
               expectations: [
                 %Expectation{
                   name: "timeout",
                   type: :expect,
                   expression: "corosync_token_timeout == 30000"
                 }
               ]
             } = Catalog.get_check("expect_check")
    end

    test "should load a critical as default severity" do
      assert %Check{severity: :critical} = Catalog.get_check("expect_same_check")
    end

    test "should load a warning severity" do
      assert %Check{severity: :warning} = Catalog.get_check("warning_severity_check")
    end

    test "should load checks with values" do
      assert %Check{
               values: [
                 %Value{
                   conditions: [
                     %Condition{expression: "some_expression", value: 10},
                     %Condition{expression: "some_other_expression", value: 15}
                   ],
                   default: 5,
                   name: "expected_value"
                 },
                 %Value{
                   conditions: [
                     %Condition{expression: "some_third_expression", value: 5}
                   ],
                   default: 10,
                   name: "expected_higher_value"
                 }
               ]
             } = Catalog.get_check("with_values_check")
    end
  end
end

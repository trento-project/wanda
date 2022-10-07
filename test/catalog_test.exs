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
               id: "test_check",
               name: "Test check",
               severity: :critical,
               facts: [
                 %Fact{
                   name: "jedi",
                   gatherer: "wandalorian",
                   argument: "-o"
                 }
               ],
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
               ],
               expectations: [
                 %Expectation{
                   name: "some_expectation",
                   type: :expect,
                   expression: "jedi == values.expected_value"
                 },
                 %Expectation{
                   name: "some_other_expectation",
                   type: :expect,
                   expression: "jedi > values.expected_higher_value"
                 }
               ]
             } = Catalog.get_check("expect_check")
    end

    test "should load a expect_same expectation type" do
      assert %Check{
               values: [],
               expectations: [
                 %Expectation{
                   name: "some_expectation",
                   type: :expect_same,
                   expression: "jedi"
                 }
               ]
             } = Catalog.get_check("expect_same_check")
    end

    test "should load a warning severity" do
      assert %Check{severity: :warning} = Catalog.get_check("warning_severity_check")
    end
  end
end

defmodule Wanda.ExecutionTest do
  use ExUnit.Case

  import Wanda.Factory

  alias Wanda.Execution

  describe "execution" do
    test "should load checks properly" do
      targets = build_list(2, :target, checks: ["expect_check"])

      assert [
               %Wanda.Catalog.Check{id: "expect_check"}
             ] = Execution.get_checks_from_targets(targets)
    end

    test "should load checks properly if the targets have different checks" do
      target_1 = build(:target, checks: ["expect_check"])
      target_2 = build(:target, checks: ["expect_same_check"])

      assert [
               %Wanda.Catalog.Check{id: "expect_check"},
               %Wanda.Catalog.Check{id: "expect_same_check"}
             ] = Execution.get_checks_from_targets([target_1, target_2])
    end

    test "should load return no checks if the targets don't have them" do
      targets = build_list(2, :target, checks: [])
      assert [] = Execution.get_checks_from_targets(targets)
    end
  end
end

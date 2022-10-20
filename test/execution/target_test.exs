defmodule Wanda.Execution.TargetTest do
  use ExUnit.Case

  import Wanda.Factory

  alias Wanda.Execution.Target

  describe "target" do
    test "should load checks properly when the targets have the same checks" do
      checks = ["check1", "check2", "check3"]

      targets = build_list(2, :target, checks: checks)

      assert ^checks = Target.get_checks_from_targets(targets)
    end

    test "should load checks properly when the targets have different checks" do
      checks_1 = ["check1", "check2", "check3"]
      checks_2 = ["check4", "check5", "check6"]

      %{checks: checks_1} = target_1 = build(:target, checks: checks_1)
      %{checks: checks_2} = target_2 = build(:target, checks: checks_2)

      checks = Enum.concat(checks_1, checks_2)

      assert ^checks = Target.get_checks_from_targets([target_1, target_2])
    end

    test "should load no checks when the targets don't have them" do
      targets = build_list(2, :target, checks: [])
      assert [] = Target.get_checks_from_targets(targets)
    end
  end
end

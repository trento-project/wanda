defmodule Wanda.Executions.TargetTest do
  use ExUnit.Case

  import Wanda.Factory

  alias Wanda.Executions.Target

  describe "target" do
    test "should return checks properly when the targets have the same checks" do
      checks = ["check1", "check2", "check3"]

      targets = build_list(2, :target, checks: checks)

      assert ^checks = Target.get_checks_from_targets(targets)
    end

    test "should return checks properly when the targets have different checks" do
      checks_1 = ["check1", "check2", "check3"]
      checks_2 = ["check4", "check5", "check6"]

      %{checks: checks_1} = target_1 = build(:target, checks: checks_1)
      %{checks: checks_2} = target_2 = build(:target, checks: checks_2)

      checks = Enum.concat(checks_1, checks_2)

      assert ^checks = Target.get_checks_from_targets([target_1, target_2])
    end

    test "should return no checks when the targets don't have them" do
      targets = build_list(2, :target, checks: [])
      assert [] = Target.get_checks_from_targets(targets)
    end

    test "should map plain structs to the Wanda.Executions.Target" do
      targets = [
        build(:target,
          agent_id: agent_1 = Faker.UUID.v4(),
          checks: [
            check_1 = Faker.Airports.iata(),
            check_2 = Faker.Cannabis.brand()
          ]
        ),
        build(:target,
          agent_id: agent_2 = Faker.UUID.v4(),
          checks: [
            check_3 = Faker.Color.name()
          ]
        )
      ]

      assert [
               %Target{
                 agent_id: ^agent_1,
                 checks: [
                   ^check_1,
                   ^check_2
                 ]
               },
               %Target{
                 agent_id: ^agent_2,
                 checks: [
                   ^check_3
                 ]
               }
             ] = Target.map_targets(targets)
    end

    test "should deduplicate targets" do
      duplicated_agent_id = Faker.UUID.v4()

      targets = build_list(3, :target, agent_id: duplicated_agent_id) ++ build_list(2, :target)

      assert 3 ==
               targets
               |> Target.map_targets()
               |> length()
    end
  end
end

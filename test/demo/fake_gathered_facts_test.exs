defmodule Wanda.Executions.FakeGatheredFactsTest do
  @moduledoc false

  use ExUnit.Case

  import Wanda.Factory

  alias Wanda.Executions.Fact, as: ExecutionFact
  alias Wanda.Executions.FakeGatheredFacts

  describe "Generation of fake gathered facts" do
    test "get_demo_gathered_facts generates the fake gathered facts" do
      check_id_1 = "CHECK1"
      check_id_2 = "CHECK2"
      check_id_3 = "CHECK3"

      agent_id_1 = "0a055c90-4cb6-54ce-ac9c-ae3fedaf40d4"
      agent_id_2 = "13e8c25c-3180-5a9a-95c8-51ec38e50cfc"
      agent_id_3 = "99cf8a3a-48d6-57a4-b302-6e4482227ab6"

      fact_name1 = "fact_name1"
      fact_name2 = "fact_name2"
      fact_name3 = "fact_name3"
      not_configured_fact_name = Faker.StarWars.character()

      check1_facts = build_list(1, :catalog_fact, name: fact_name1)

      check2_facts = [
        build(:catalog_fact, name: not_configured_fact_name),
        build(:catalog_fact, name: fact_name2)
      ]

      check3_facts = [
        build(:catalog_fact, name: fact_name3)
      ]

      checks = [
        build(:check, id: check_id_1, facts: check1_facts),
        build(:check, id: check_id_2, facts: check2_facts),
        build(:check, id: check_id_3, facts: check3_facts)
      ]

      not_configured_target_id = Faker.UUID.v4()

      targets = [
        build(:target, agent_id: agent_id_1, checks: [check_id_1, check_id_2, check_id_3]),
        build(:target, agent_id: agent_id_2, checks: [check_id_1, check_id_2, check_id_3]),
        build(:target, agent_id: agent_id_3, checks: [check_id_1, check_id_2, check_id_3]),
        build(:target,
          agent_id: not_configured_target_id,
          checks: [check_id_1, check_id_2, check_id_3]
        )
      ]

      assert %{
               ^check_id_1 => %{
                 ^agent_id_1 => [
                   %ExecutionFact{check_id: ^check_id_1, name: ^fact_name1, value: 2}
                 ],
                 ^agent_id_2 => [
                   %ExecutionFact{check_id: ^check_id_1, name: ^fact_name1, value: 3}
                 ],
                 ^agent_id_3 => [
                   %ExecutionFact{check_id: ^check_id_1, name: ^fact_name1, value: nil}
                 ],
                 ^not_configured_target_id => [
                   %ExecutionFact{
                     check_id: ^check_id_1,
                     name: ^fact_name1,
                     value: "some fact value"
                   }
                 ]
               },
               ^check_id_2 => %{
                 ^agent_id_1 => [
                   %ExecutionFact{
                     check_id: ^check_id_2,
                     name: ^not_configured_fact_name,
                     value: "some fact value"
                   },
                   %ExecutionFact{
                     check_id: ^check_id_2,
                     name: ^fact_name2,
                     value: %{"property1" => %{"some_sub_prop" => 15}}
                   }
                 ],
                 ^agent_id_2 => [
                   %ExecutionFact{
                     check_id: ^check_id_2,
                     name: ^not_configured_fact_name,
                     value: "some fact value"
                   },
                   %ExecutionFact{
                     check_id: ^check_id_2,
                     name: ^fact_name2,
                     value: %{"property2" => %{"some_sub_prop" => 60}}
                   }
                 ],
                 ^agent_id_3 => [
                   %ExecutionFact{
                     check_id: ^check_id_2,
                     name: ^not_configured_fact_name,
                     value: "some fact value"
                   },
                   %ExecutionFact{
                     check_id: ^check_id_2,
                     name: ^fact_name2,
                     value: %{"property3" => %{"some_sub_prop" => 60}}
                   }
                 ],
                 ^not_configured_target_id => [
                   %ExecutionFact{
                     check_id: ^check_id_2,
                     name: ^not_configured_fact_name,
                     value: "some fact value"
                   },
                   %ExecutionFact{
                     check_id: ^check_id_2,
                     name: ^fact_name2,
                     value: "some fact value"
                   }
                 ]
               },
               ^check_id_3 => %{
                 ^agent_id_1 => [
                   %ExecutionFact{
                     check_id: ^check_id_3,
                     name: ^fact_name3,
                     value: "/dev/sdb;/dev/sdc;dev/sdg"
                   }
                 ],
                 ^agent_id_2 => [
                   %ExecutionFact{
                     check_id: ^check_id_3,
                     name: ^fact_name3,
                     value: "some fact value"
                   }
                 ],
                 ^agent_id_3 => [
                   %ExecutionFact{
                     check_id: ^check_id_3,
                     name: ^fact_name3,
                     value: "/dev/sdb;/dev/sdc;dev/sdg"
                   }
                 ],
                 ^not_configured_target_id => [
                   %ExecutionFact{
                     check_id: ^check_id_3,
                     name: ^fact_name3,
                     value: "some fact value"
                   }
                 ]
               }
             } = FakeGatheredFacts.get_demo_gathered_facts(checks, targets)
    end
  end
end

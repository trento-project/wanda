defmodule Wanda.Executions.FakeGatheredFactsTest do
  @moduledoc false

  use ExUnit.Case

  import Wanda.Factory

  alias Wanda.Catalog.Fact
  alias Wanda.Executions.Fact, as: ExecutionFact
  alias Wanda.Executions.FakeGatheredFacts

  describe "Generation of fake gathered facts" do
    test "get_demo_gathered_facts generates the fake gathered facts" do
      check_id_1 = Faker.UUID.v4()
      check_id_2 = Faker.UUID.v4()

      agent_id_1 = Faker.UUID.v4()
      agent_id_2 = Faker.UUID.v4()

      [
        %Fact{
          name: fact_name_1
        }
      ] = check1_facts = build_list(1, :catalog_fact)

      [
        %Fact{
          name: fact_name_2
        },
        %Fact{
          name: fact_name_3
        }
      ] = check2_facts = build_list(2, :catalog_fact)

      Application.put_env(:wanda, :fake_gathered_facts, %{
        check_id_1 => %{
          agent_id_1 => %{
            fact_name_1 => fact_value1_agent_1 = Faker.Lorem.word()
          },
          agent_id_2 => %{
            fact_name_1 => fact_value1_agent_2 = Faker.StarWars.character()
          }
        },
        check_id_2 => %{
          agent_id_1 => %{
            fact_name_2 => fact_value2_agent_1 = Faker.Cannabis.brand()
            # fact_value3_agent_1 should have fallback fact value
          },
          agent_id_2 => %{
            fact_name_2 => fact_value2_agent_2 = Faker.Beer.alcohol(),
            fact_name_3 => fact_value3_agent_2 = nil
          }
        }
      })

      checks = [
        build(:check, id: check_id_1, facts: check1_facts),
        build(:check, id: check_id_2, facts: check2_facts)
      ]

      targets = [
        build(:target, agent_id: agent_id_1, checks: [check_id_1, check_id_2]),
        build(:target, agent_id: agent_id_2, checks: [check_id_1, check_id_2])
      ]

      assert %{
               ^check_id_2 => %{
                 ^agent_id_1 => [
                   %ExecutionFact{
                     check_id: ^check_id_2,
                     name: ^fact_name_2,
                     value: ^fact_value2_agent_1
                   },
                   %ExecutionFact{
                     check_id: ^check_id_2,
                     name: ^fact_name_3,
                     value: "some fact value"
                   }
                 ],
                 ^agent_id_2 => [
                   %ExecutionFact{
                     check_id: ^check_id_2,
                     name: ^fact_name_2,
                     value: ^fact_value2_agent_2
                   },
                   %ExecutionFact{
                     check_id: ^check_id_2,
                     name: ^fact_name_3,
                     value: ^fact_value3_agent_2
                   }
                 ]
               },
               ^check_id_1 => %{
                 ^agent_id_1 => [
                   %ExecutionFact{
                     check_id: ^check_id_1,
                     name: ^fact_name_1,
                     value: ^fact_value1_agent_1
                   }
                 ],
                 ^agent_id_2 => [
                   %ExecutionFact{
                     check_id: ^check_id_1,
                     name: ^fact_name_1,
                     value: ^fact_value1_agent_2
                   }
                 ]
               }
             } = FakeGatheredFacts.get_demo_gathered_facts(checks, targets)
    end
  end
end

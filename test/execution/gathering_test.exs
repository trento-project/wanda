defmodule Wanda.Execution.GatheringTest do
  use ExUnit.Case

  import Wanda.Factory

  alias Wanda.Execution.{
    Fact,
    Gathering,
    Target
  }

  describe "put gathered facts" do
    test "should put the gathered facts for the proper agent id" do
      agent_id_1 = UUID.uuid4()
      [%Fact{check_id: check_id_1, name: name_1, value: value_1}] = facts = build_list(1, :fact)

      assert %{
               ^agent_id_1 => %{
                 ^check_id_1 => %{
                   ^name_1 => ^value_1
                 }
               }
             } = gathered_facts = Gathering.put_gathered_facts(%{}, agent_id_1, facts)

      agent_id_2 = UUID.uuid4()

      [
        %Fact{check_id: check_id_2, name: name_2, value: value_2},
        %Fact{check_id: check_id_3, name: name_3, value: value_3}
      ] = facts = build_list(2, :fact)

      assert %{
               ^agent_id_1 => %{
                 ^check_id_1 => %{
                   ^name_1 => ^value_1
                 }
               },
               ^agent_id_2 => %{
                 ^check_id_2 => %{
                   ^name_2 => ^value_2
                 },
                 ^check_id_3 => %{
                   ^name_3 => ^value_3
                 }
               }
             } = Gathering.put_gathered_facts(gathered_facts, agent_id_2, facts)
    end
  end

  describe "target" do
    test "should return true if the agent_id is present inside targets" do
      [%Target{agent_id: agent_id} | _] = targets = build_list(Enum.random(1..100), :target)

      assert Gathering.target?(targets, agent_id)
    end

    test "should return false if the agent_id is not present inside targets" do
      targets = build_list(Enum.random(1..100), :target)

      refute Gathering.target?(targets, UUID.uuid4())
    end
  end

  describe "all agents sent facts" do
    test "should return true if all the agents have sent facts" do
      [%Target{agent_id: agent_id} | _] = targets = build_list(1, :target)

      gathered_facts = %{
        agent_id => %{
          "check_1" => %{
            "fact_name" => "fact_value"
          }
        }
      }

      assert Gathering.all_agents_sent_facts?(gathered_facts, targets)
    end

    test "should return false if all the agents have not sent facts" do
      [%Target{agent_id: agent_id} | _] = targets = build_list(2, :target)

      gathered_facts = %{
        agent_id => %{
          "check_1" => %{
            "fact_name" => "fact_value"
          }
        }
      }

      refute Gathering.all_agents_sent_facts?(gathered_facts, targets)
    end
  end
end

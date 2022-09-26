defmodule Wanda.Execution.GatheringTest do
  use ExUnit.Case

  import Wanda.Factory

  alias Wanda.Execution.{
    Fact,
    FactError,
    Gathering,
    Target
  }

  describe "put gathered facts" do
    test "should put the gathered facts for the proper agent id" do
      agent_id_1 = UUID.uuid4()
      [%Fact{check_id: check_id_1, name: name_1, value: value_1}] = facts = build_list(1, :fact)

      assert %{
               ^check_id_1 => %{
                 ^agent_id_1 => %{
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
               ^check_id_1 => %{
                 ^agent_id_1 => %{
                   ^name_1 => ^value_1
                 }
               },
               ^check_id_2 => %{
                 ^agent_id_2 => %{
                   ^name_2 => ^value_2
                 }
               },
               ^check_id_3 => %{
                 ^agent_id_2 => %{
                   ^name_3 => ^value_3
                 }
               }
             } = Gathering.put_gathered_facts(gathered_facts, agent_id_2, facts)
    end

    test "should put the gathered facts with errors for the proper agent id" do
      agent_id_1 = UUID.uuid4()
      check_id_1 = UUID.uuid4()

      [
        %Fact{name: name_1, value: value_1}
      ] = facts = build_list(1, :fact, check_id: check_id_1)

      [
        %FactError{name: name_2, type: type_2, message: msg_2}
      ] = facts_error = build_list(1, :fact_error, check_id: check_id_1)

      assert %{
               ^check_id_1 => %{
                 ^agent_id_1 => %{
                   ^name_1 => ^value_1,
                   ^name_2 => %{
                     message: ^msg_2,
                     type: ^type_2
                   }
                 }
               }
             } =
               gathered_facts =
               Gathering.put_gathered_facts(%{}, agent_id_1, facts ++ facts_error)

      agent_id_2 = UUID.uuid4()

      [
        %FactError{check_id: check_id_3, name: name_3, type: type_3, message: msg_3}
      ] = facts_error = build_list(1, :fact_error)
      [
        %Fact{check_id: check_id_4, name: name_4, value: value_4}
      ] = facts = build_list(1, :fact)

      assert %{
               ^check_id_1 => %{
                 ^agent_id_1 => %{
                   ^name_1 => ^value_1,
                   ^name_2 => %{
                     message: ^msg_2,
                     type: ^type_2
                   }
                 }
               },
               ^check_id_3 => %{
                 ^agent_id_2 => %{
                   ^name_3 => %{
                     message: ^msg_3,
                     type: ^type_3
                   }
                 }
               },
               ^check_id_4 => %{
                 ^agent_id_2 => %{
                   ^name_4 => ^value_4
                 }
               }
             } = Gathering.put_gathered_facts(gathered_facts, agent_id_2, facts_error ++ facts)
    end
  end

  describe "put gathering timeouts" do
    test "should put gathering timeouts for the proper agents" do
      agent_id_1 = UUID.uuid4()
      [%Fact{check_id: check_id_1, name: name_1, value: value_1}] = facts = build_list(1, :fact)

      gathered_facts = Gathering.put_gathered_facts(%{}, agent_id_1, facts)

      agent_id_2 = UUID.uuid4()

      [
        %Fact{check_id: check_id_2, name: name_2, value: value_2},
        %Fact{check_id: check_id_3, name: name_3, value: value_3}
      ] = facts = build_list(2, :fact)

      gathered_facts = Gathering.put_gathered_facts(gathered_facts, agent_id_2, facts)

      timeout_agent_id_1 = UUID.uuid4()
      timeout_agent_id_2 = UUID.uuid4()
      timeout_check_id = UUID.uuid4()

      timeout_targets = [
        %Target{agent_id: timeout_agent_id_1, checks: [timeout_check_id]},
        %Target{agent_id: timeout_agent_id_2, checks: [timeout_check_id, check_id_3]}
      ]

      assert %{
               ^check_id_1 => %{
                 ^agent_id_1 => %{
                   ^name_1 => ^value_1
                 }
               },
               ^check_id_2 => %{
                 ^agent_id_2 => %{
                   ^name_2 => ^value_2
                 }
               },
               ^check_id_3 => %{
                 ^agent_id_2 => %{
                   ^name_3 => ^value_3
                 },
                 ^timeout_agent_id_2 => :timeout
               },
               ^timeout_check_id => %{
                 ^timeout_agent_id_1 => :timeout,
                 ^timeout_agent_id_2 => :timeout
               }
             } = Gathering.put_gathering_timeouts(gathered_facts, timeout_targets)
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
      targets =
        1..10
        |> Enum.random()
        |> build_list(:target)

      agents_gathered = Enum.map(targets, & &1.agent_id)

      assert Gathering.all_agents_sent_facts?(agents_gathered, targets)
    end

    test "should return false if all the agents have not sent facts" do
      targets =
        1..10
        |> Enum.random()
        |> build_list(:target)

      agents_gathered = ["agent_007"]

      refute Gathering.all_agents_sent_facts?(agents_gathered, targets)
    end
  end
end

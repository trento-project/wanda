defmodule Wanda.PolicyTest do
  use ExUnit.Case

  import Mox

  alias Trento.Checks.V1.{
    ExecutionRequested,
    FactsGathered
  }

  alias Wanda.Execution.{Fact, Target}

  setup :verify_on_exit!

  test "should handle a ExecutionRequested event" do
    execution_id = UUID.uuid4()
    group_id = UUID.uuid4()
    agent_id = UUID.uuid4()

    expect(Wanda.Execution.Mock, :start_execution, fn ^execution_id,
                                                      ^group_id,
                                                      [
                                                        %Target{
                                                          agent_id: ^agent_id,
                                                          checks: ["check_id"]
                                                        }
                                                      ] ->
      :ok
    end)

    assert :ok =
             %{
               execution_id: execution_id,
               group_id: group_id,
               targets: [%{agent_id: agent_id, checks: ["check_id"]}]
             }
             |> ExecutionRequested.new!()
             |> Wanda.Policy.handle_event()
  end

  test "should handle a FactsGathered event" do
    execution_id = UUID.uuid4()
    agent_id = UUID.uuid4()

    expect(Wanda.Execution.Mock, :receive_facts, fn ^execution_id,
                                                    ^agent_id,
                                                    [
                                                      %Fact{
                                                        check_id: "check_id",
                                                        name: "name",
                                                        value: "value"
                                                      }
                                                    ] ->
      :ok
    end)

    assert :ok =
             %{
               execution_id: execution_id,
               agent_id: agent_id,
               facts_gathered: [%{check_id: "check_id", name: "name", value: {:text_value, "value"}}]
             }
             |> FactsGathered.new!()
             |> Wanda.Policy.handle_event()
  end
end

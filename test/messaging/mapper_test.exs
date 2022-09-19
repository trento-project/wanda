defmodule Wanda.Messaging.MapperTest do
  @moduledoc false

  use ExUnit.Case

  import Wanda.Factory

  alias Wanda.Messaging.Mapper

  alias Wanda.Catalog.{Check, Fact}
  alias Wanda.Execution.Target

  alias Trento.Checks.V1.{
    ExecutionCompleted,
    FactsGatheringRequested
  }

  test "should map to a FactGatheringRequested event" do
    execution_id = UUID.uuid4()
    group_id = UUID.uuid4()

    targets = [
      %Target{agent_id: "agent_1", checks: ["check_1", "check_2"]},
      %Target{agent_id: "agent_2", checks: ["check_3"]}
    ]

    checks = [
      %Check{
        id: "check_1",
        facts: [
          %Fact{name: "fact_1", gatherer: "gatherer_1", argument: "argument_1"},
          %Fact{name: "fact_2", gatherer: "gatherer_2", argument: "argument_2"}
        ]
      },
      %Check{
        id: "check_2",
        facts: [%Fact{name: "fact_2", gatherer: "gatherer_2", argument: "argument_2"}]
      },
      %Check{
        id: "check_3",
        facts: [%Fact{name: "fact_3", gatherer: "gatherer_3", argument: "argument_3"}]
      }
    ]

    assert %FactsGatheringRequested{
             execution_id: ^execution_id,
             group_id: ^group_id,
             targets: [
               %{
                 agent_id: "agent_1",
                 fact_requests: [
                   %{
                     argument: "argument_1",
                     check_id: "check_1",
                     gatherer: "gatherer_1",
                     name: "fact_1"
                   },
                   %{
                     argument: "argument_2",
                     check_id: "check_1",
                     gatherer: "gatherer_2",
                     name: "fact_2"
                   },
                   %{
                     argument: "argument_2",
                     check_id: "check_2",
                     gatherer: "gatherer_2",
                     name: "fact_2"
                   }
                 ]
               },
               %{
                 agent_id: "agent_2",
                 fact_requests: [
                   %{
                     argument: "argument_3",
                     check_id: "check_3",
                     gatherer: "gatherer_3",
                     name: "fact_3"
                   }
                 ]
               }
             ]
           } = Mapper.to_facts_gathering_requested(execution_id, group_id, targets, checks)
  end

  test "should map to an ExecutionCompletedV1 event" do
    execution_id = UUID.uuid4()
    group_id = UUID.uuid4()

    execution_result = build(:execution_result, execution_id: execution_id, group_id: group_id)

    assert %ExecutionCompleted{
             execution_id: ^execution_id,
             group_id: ^group_id,
             result: :PASSING,
             check_results: [
               %{
                 check_id: "expect_check",
                 agents_check_results: [
                   %{
                     agent_id: "agent_1",
                     facts: [%{name: "corosync_timeout", value: 1000}],
                     evaluations: [
                       %{
                         evaluations: %{
                           name: "corosync_timeout",
                           return_value: true,
                           type: :EXPECT
                         }
                       }
                     ]
                   },
                   %{
                     agent_id: "agent_2",
                     facts: [%{name: "corosync_timeout", value: 1000}],
                     evaluations: [
                       %{
                         evaluations: %{
                           name: "corosync_timeout",
                           return_value: true,
                           type: :EXPECT
                         }
                       },
                       %{
                         evaluations: %{
                           name: "corosync_timeout",
                           message: "error_message",
                           type: :FACT_MISSING_ERROR
                         }
                       }
                     ]
                   }
                 ],
                 expectation_results: [%{name: "corosync_timeout", result: true, type: :EXPECT}],
                 result: :PASSING
               }
             ]
           } = Mapper.to_execution_completed(execution_result)
  end
end

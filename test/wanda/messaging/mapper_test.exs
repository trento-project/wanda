defmodule Wanda.Messaging.MapperTest do
  @moduledoc false

  use ExUnit.Case

  import Wanda.Factory

  alias Wanda.Messaging.Mapper

  alias Wanda.Catalog.{Check, Fact}
  alias Wanda.Executions

  alias Trento.Checks.V1.{
    ExecutionCompleted,
    ExecutionRequested,
    ExecutionStarted,
    FactsGathered,
    FactsGatheringRequested,
    Target
  }

  test "should map to ExecutionStarted event" do
    execution_id = UUID.uuid4()
    group_id = UUID.uuid4()

    targets = [
      %Executions.Target{agent_id: "agent_1", checks: ["check_1", "check_2"]},
      %Executions.Target{agent_id: "agent_2", checks: ["check_3"]}
    ]

    assert %ExecutionStarted{
             execution_id: ^execution_id,
             group_id: ^group_id,
             targets: [
               %Target{
                 agent_id: "agent_1",
                 checks: ["check_1", "check_2"]
               },
               %Target{
                 agent_id: "agent_2",
                 checks: ["check_3"]
               }
             ]
           } = Mapper.to_execution_started(execution_id, group_id, targets)
  end

  test "should map to a FactGatheringRequested event" do
    execution_id = UUID.uuid4()
    group_id = UUID.uuid4()

    targets = [
      %Executions.Target{agent_id: "agent_1", checks: ["check_1", "check_2"]},
      %Executions.Target{agent_id: "agent_2", checks: ["check_3"]}
    ]

    checks = [
      %Check{
        id: "check_1",
        facts: [
          %Fact{name: "fact_1", gatherer: "gatherer_1", argument: "argument_1"},
          %Fact{name: "fact_2", gatherer: "gatherer_2", argument: "argument_2"},
          %Fact{name: "fact_3", gatherer: "no_args_gatherer", argument: ""}
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
                     argument: "",
                     check_id: "check_1",
                     gatherer: "no_args_gatherer",
                     name: "fact_3"
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
    target_type = Faker.StarWars.character()

    result_map = %{passing: :PASSING, warning: :WARNING, critical: :CRITICAL}

    Enum.each(result_map, fn {domain_result, event_result} ->
      execution =
        build(:result,
          execution_id: execution_id,
          group_id: group_id,
          result: domain_result
        )

      assert %ExecutionCompleted{
               execution_id: ^execution_id,
               group_id: ^group_id,
               result: ^event_result,
               target_type: ^target_type
             } = Mapper.to_execution_completed(execution, target_type)
    end)
  end

  test "should map from ExecutionRequestedV1 event" do
    execution_id = UUID.uuid4()
    group_id = UUID.uuid4()

    execution = %ExecutionRequested{
      execution_id: execution_id,
      group_id: group_id,
      targets: [
        %{
          agent_id: "agent1",
          checks: ["check_1", "check_2"]
        },
        %{
          agent_id: "agent3",
          checks: ["check_3", "check_4"]
        }
      ],
      env: %{
        some_string: %{
          kind: {:string_value, "some_string"}
        },
        some_number: %{
          kind: {:number_value, 10}
        },
        some_boolean: %{
          kind: {:boolean_value, true}
        },
        null: %{
          kind: {:null_value}
        }
      }
    }

    assert %{
             execution_id: ^execution_id,
             group_id: ^group_id,
             targets: [
               %Executions.Target{
                 agent_id: "agent1",
                 checks: ["check_1", "check_2"]
               },
               %Executions.Target{
                 agent_id: "agent3",
                 checks: ["check_3", "check_4"]
               }
             ],
             env: %{
               some_string: "some_string",
               some_number: 10,
               some_boolean: true,
               null: nil
             }
           } = Mapper.from_execution_requested(execution)
  end

  test "should map from FactsGathered event" do
    execution_id = UUID.uuid4()
    group_id = UUID.uuid4()
    agent_id = UUID.uuid4()

    facts = %FactsGathered{
      execution_id: execution_id,
      group_id: group_id,
      agent_id: agent_id,
      facts_gathered: [
        %{
          check_id: "check1",
          name: "string_value",
          fact_value: {:value, %{kind: {:string_value, "some_string"}}}
        },
        %{
          check_id: "check2",
          name: "integer_value",
          fact_value: {:value, %{kind: {:number_value, 10.0}}}
        },
        %{
          check_id: "check2",
          name: "float_value",
          fact_value: {:value, %{kind: {:number_value, 10.2}}}
        },
        %{
          check_id: "check3",
          name: "boolean_value",
          fact_value: {:value, %{kind: {:boolean_value, true}}}
        },
        %{
          check_id: "check4",
          name: "nil_value",
          fact_value: {:value, %{kind: {:null_value, :NULL_VALUE}}}
        },
        %{
          check_id: "check5",
          name: "list_value",
          fact_value:
            {:value,
             %{
               kind:
                 {:list_value,
                  %{
                    values: [
                      %{kind: {:number_value, 10.0}},
                      %{
                        kind:
                          {:list_value,
                           %{
                             values: [
                               %{kind: {:boolean_value, true}}
                             ]
                           }}
                      }
                    ]
                  }}
             }}
        },
        %{
          check_id: "check6",
          name: "struct_value",
          fact_value:
            {:value,
             %{
               kind:
                 {:struct_value,
                  %{
                    fields: %{
                      some_key: %{
                        kind:
                          {:struct_value,
                           %{
                             fields: %{
                               other_key: %{kind: {:number_value, 10.0}},
                               third_key: %{kind: {:number_value, 15.0}}
                             }
                           }}
                      }
                    }
                  }}
             }}
        },
        %{
          check_id: "check7",
          name: "fact_error",
          fact_value: {:error_value, %{type: "error_type", message: "Error!"}}
        }
      ]
    }

    assert %{
             execution_id: ^execution_id,
             group_id: ^group_id,
             agent_id: ^agent_id,
             facts_gathered: [
               %Executions.Fact{check_id: "check1", name: "string_value", value: "some_string"},
               %Executions.Fact{check_id: "check2", name: "integer_value", value: 10},
               %Executions.Fact{check_id: "check2", name: "float_value", value: 10.2},
               %Executions.Fact{check_id: "check3", name: "boolean_value", value: true},
               %Executions.Fact{check_id: "check4", name: "nil_value", value: nil},
               %Executions.Fact{check_id: "check5", name: "list_value", value: [10, [true]]},
               %Executions.Fact{
                 check_id: "check6",
                 name: "struct_value",
                 value: %{some_key: %{other_key: 10, third_key: 15}}
               },
               %Executions.FactError{
                 check_id: "check7",
                 name: "fact_error",
                 type: "error_type",
                 message: "Error!"
               }
             ]
           } = Mapper.from_facts_gathererd(facts)
  end
end

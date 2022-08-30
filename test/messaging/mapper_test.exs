defmodule Wanda.MapperTest do
  @moduledoc false

  use ExUnit.Case

  import Wanda.Factory

  alias Wanda.Messaging.Mapper

  alias Wanda.Support.CloudEventsHelper
  alias Wanda.Support.Messaging.DummyEvent

  describe "serializing outgoing events" do
    test "should produce an error for unsupported events" do
      assert {:error, :unsupported_event} = Mapper.to_json(%DummyEvent{})
    end

    test "should produce a serialized ExecutionCompletedV1 cloud event" do
      execution_result =
        build(:execution_result,
          execution_id: "d9955082-42c9-4835-b53a-3a4d3b2e4a9c",
          group_id: "421af233-dbb2-4328-907e-8b355b00bde8"
        )

      expected_cloud_event = CloudEventsHelper.load_event("execution_completed_succesfully")

      assert expected_cloud_event == Mapper.to_json(execution_result)
    end

    test "should produce an ExecutionCompletedV1 with a valid event data, as per the schema" do
      execution_result = build(:execution_result)
      event_type = "trento.checks.v1.ExecutionCompleted"

      %{"data" => event_data, "type" => ^event_type} =
        execution_result
        |> Mapper.to_json()
        |> Jason.decode!()

      assert :ok = Wanda.JsonSchema.validate(event_type, event_data)
    end

    test "should produce a serialized FactsGatheringRequestedV1 cloud event" do
      facts_request =
        build(
          :facts_request,
          execution_id: "dec60401-8f33-45d7-bbd5-f42a3f9e9b48",
          group_id: "421af233-dbb2-4328-907e-8b355b00bde8",
          targets: ["37b6a7ea-3f2e-45ed-b762-23bd39129a90"],
          facts: [
            %Wanda.Execution.AgentFacts{
              agent_id: "37b6a7ea-3f2e-45ed-b762-23bd39129a90",
              facts: [
                %Wanda.Catalog.Fact{
                  check_id: "CHK01",
                  name: "some_fact_name",
                  gatherer: "some_gatherer",
                  argument: "some_argument"
                },
                %Wanda.Catalog.Fact{
                  check_id: "CHK02",
                  name: "another_fact_name",
                  gatherer: "another_gatherer",
                  argument: "another_argument"
                }
              ]
            }
          ]
        )

      expected_cloud_event = CloudEventsHelper.load_event("facts_gathering_requested")

      assert expected_cloud_event == Mapper.to_json(facts_request)
    end

    test "should produce an FactsGatheringRequestedV1 with a valid event data, as per the schema" do
      facts_request = build(:facts_request)
      event_type = "trento.checks.v1.FactsGatheringRequested"

      %{"data" => event_data, "type" => ^event_type} =
        facts_request
        |> Mapper.to_json()
        |> Jason.decode!()

      assert :ok = Wanda.JsonSchema.validate(event_type, event_data)
    end
  end
end

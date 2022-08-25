defmodule Wanda.MapperTest do
  @moduledoc false

  use ExUnit.Case

  import Wanda.Factory

  alias Wanda.Messaging.Mapper

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

      expected_cloud_event =
        File.read!("test/fixtures/events/execution_completed_succesfully.json")
        |> String.replace(["\r", "\n", " "], "")

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
  end
end

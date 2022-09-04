defmodule Wanda do
  @moduledoc false

  def fake_web_request do
    execution_requested = %{
      "execution_id" => execution_id = UUID.uuid4(),
      "group_id" => UUID.uuid4(),
      "targets" => [
        %{
          "agent_id" => "08201877-886a-57d3-8427-b812aee61148",
          "checks" => ["156F64"]
        },
        %{
          "agent_id" => "d31b8b5e-4698-57b8-8f38-362540c5f43d",
          "checks" => ["156F64"]
        },
        %{
          "agent_id" => "73704145-e5f4-56ad-8438-16d83800bff6",
          "checks" => ["156F64"]
        },
        %{
          "agent_id" => "3319bc92-0c3f-52c8-81bc-3ecdd4764084",
          "checks" => ["156F64"]
        }
      ]
    }

    Wanda.Messaging.Adapters.AMQP.publish(
      "checks.executions.start-#{execution_id}",
      execution_requested
    )
  end
end

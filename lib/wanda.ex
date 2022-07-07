defmodule Wanda do
  @moduledoc false

  def start_check_execution() do
    execution_id = UUID.uuid4()
    cluster_id = UUID.uuid4()

    check_execution = %Wanda.CheckExecution{
      execution_id: execution_id,
      cluster_id: cluster_id,
      targets_selections: [
        %{
          host_id: UUID.uuid4(),
          checks: [
            "CHK1",
            "CHK2",
            "CHK3"
          ]
        },
        %{
          host_id: UUID.uuid4(),
          checks: [
            "CHK4",
            "CHK3",
            "CHK6",
            "CHK7"
          ]
        },
        %{
          host_id: UUID.uuid4(),
          checks: []
        }
      ]
    }

    Wanda.ExecutionSupervisor.start_child(execution_id)

    Wanda.ExecutionServer.start_execution(execution_id, check_execution)

    execution_id
  end

  def kaboom do
    Enum.each(1..20, fn _ -> start_check_execution() end)
  end

  def receive_gathered_facts() do
  end
end

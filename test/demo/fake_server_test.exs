defmodule Wanda.Executions.FakeServerTest do
  use Wanda.DataCase

  import Mox
  import Wanda.Factory

  alias Trento.Checks.V1.{
    ExecutionCompleted,
    ExecutionStarted
  }

  alias Wanda.Executions.{
    Execution,
    FakeServer
  }

  setup :verify_on_exit!

  test "start_execution publishes execution started and completed messages" do
    execution_id = UUID.uuid4()
    group_id = UUID.uuid4()
    targets = build_list(2, :target)
    env = build(:env)

    expect(Wanda.Messaging.Adapters.Mock, :publish, 2, fn
      "results", %ExecutionStarted{execution_id: ^execution_id, group_id: ^group_id} ->
        :ok

      "results", %ExecutionCompleted{execution_id: ^execution_id, group_id: ^group_id} ->
        :ok
    end)

    assert :ok = FakeServer.start_execution(execution_id, group_id, targets, env)

    assert %Execution{execution_id: ^execution_id, status: :completed} = Repo.one!(Execution)
  end
end

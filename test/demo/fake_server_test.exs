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

  alias Wanda.Executions.Messaging.Publisher

  setup :verify_on_exit!

  test "start_execution publishes execution started and completed messages" do
    execution_id = UUID.uuid4()
    group_id = UUID.uuid4()
    target_type = Faker.Person.first_name()
    targets = build_list(2, :target, checks: ["expect_check"])
    env = build(:env)

    expect(Wanda.Messaging.Adapters.Mock, :publish, 2, fn
      Publisher,
      "results",
      %ExecutionStarted{execution_id: ^execution_id, group_id: ^group_id},
      _ ->
        :ok

      Publisher,
      "results",
      %ExecutionCompleted{execution_id: ^execution_id, group_id: ^group_id},
      _ ->
        :ok
    end)

    assert :ok =
             FakeServer.start_execution(execution_id, group_id, targets, target_type, env,
               sleep: 0
             )

    assert %Execution{execution_id: ^execution_id, status: :completed} = Repo.one!(Execution)
  end
end

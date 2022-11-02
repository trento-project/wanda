defmodule Wanda.ExecutionTest do
  use ExUnit.Case

  import Mox
  import Wanda.Factory

  alias Wanda.Execution

  setup [:set_mox_from_context, :verify_on_exit!]

  describe "execution" do
    test "should skip execution if no checks are selected" do
      targets = build_list(2, :target, checks: [])

      assert {:error, :no_checks_selected} =
               Execution.start_execution(UUID.uuid4(), UUID.uuid4(), targets, %{})
    end

    test "should know if the other execution for the same group_id is running" do
      group_id = UUID.uuid4()
      targets = build_list(2, :target, checks: ["expect_check"])

      expect(Wanda.Messaging.Adapters.Mock, :publish, fn _, _ ->
        :ok
      end)

      assert {:ok, _} =
               start_supervised(
                 {Execution.Server,
                  [
                    execution_id: UUID.uuid4(),
                    group_id: group_id,
                    targets: targets,
                    checks: build_list(10, :check),
                    env: %{}
                  ]}
               )

      assert {:error, :already_running} =
               Execution.start_execution(UUID.uuid4(), group_id, targets, %{})
    end
  end
end

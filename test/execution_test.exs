defmodule Wanda.ExecutionTest do
  use ExUnit.Case

  import Wanda.Factory

  alias Wanda.Execution

  describe "execution" do
    test "should skip execution if no checks are selected" do
      targets = build_list(2, :target, checks: [])

      assert {:error, :no_checks_selected} =
               Execution.start_execution(UUID.uuid4(), UUID.uuid4(), targets, %{})
    end
  end
end

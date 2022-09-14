defmodule Wanda.Messaging.MapperTest do
  @moduledoc false

  use ExUnit.Case

  import Wanda.Factory

  alias Wanda.Messaging.Mapper

  alias Trento.Checks.V1.ExecutionCompleted

  test "should map to an ExecutionCompletedV1 event" do
    execution_id = UUID.uuid4()
    group_id = UUID.uuid4()

    execution_result = build(:execution_result, execution_id: execution_id, group_id: group_id)

    assert %ExecutionCompleted{execution_id: ^execution_id, group_id: ^group_id} =
             Mapper.to_execution_completed_event(execution_result)
  end
end

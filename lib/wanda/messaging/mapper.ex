defmodule Wanda.Messaging.Mapper do
  @moduledoc """
  Maps domain structures to integration events.
  """

  alias Wanda.Execution.Result

  alias Trento.Checks.V1.ExecutionCompleted

  def to_execution_completed_event(%Result{} = result) do
    result
    # TODO: fix oneof types
    |> Miss.Map.from_nested_struct()
    |> ExecutionCompleted.new!()
  end
end

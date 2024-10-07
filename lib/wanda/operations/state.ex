defmodule Wanda.Operations.State do
  @moduledoc """
  State of an operation.
  """

  alias Wanda.Operations.{Operation, OperationTarget}

  defstruct [
    :engine,
    :operation_id,
    :group_id,
    :operation,
    :timeout,
    targets: [],
    pending_targets_on_step: [],
    current_step_index: 0,
    agent_reports: %{},
    step_failed: false
  ]

  @type t :: %__MODULE__{
          engine: Rhai.Engine.t(),
          operation_id: String.t(),
          group_id: String.t(),
          operation: Operation.t(),
          agent_reports: map(),
          targets: [OperationTarget.t()],
          pending_targets_on_step: [String.t()],
          current_step_index: integer(),
          step_failed: boolean(),
          timeout: integer()
        }
end

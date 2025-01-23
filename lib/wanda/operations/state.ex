defmodule Wanda.Operations.State do
  @moduledoc """
  State of an operation.

  The state is composed by the next field:
  - engine: RHAI engine used to run predicate validations
  - operation_id: Identifier of this operation execution
  - group_id: Identifier of the group or resource that is under the operation.
              For example, this can be the identifier of an individual host or a cluster.
  - operation: Operation to execute
  - timeout: Timeout to stop the operation
  - pending_targets_on_step: Target ids which are pending to report back for the current operation step
  - current_step_index: Current step index being executed
  - step_failed: Whether the current step has failed in any of the targets executing it
  """

  alias Wanda.Operations.{OperationTarget, StepReport}

  alias Wanda.Operations.Catalog.Operation

  defstruct [
    :engine,
    :operation_id,
    :group_id,
    :operation,
    :timer_ref,
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
          agent_reports: [StepReport.t()],
          targets: [OperationTarget.t()],
          pending_targets_on_step: [String.t()],
          current_step_index: integer(),
          step_failed: boolean(),
          timer_ref: reference()
        }
end

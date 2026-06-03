# `Wanda.Operations.State`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/operations/state.ex#L4)

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

# `t`

```elixir
@type t() :: %Wanda.Operations.State{
  agent_reports: [Wanda.Operations.StepReport.t()],
  current_step_index: integer(),
  engine: Rhai.Engine.t(),
  group_id: String.t(),
  operation: Wanda.Operations.Catalog.Operation.t(),
  operation_id: String.t(),
  pending_targets_on_step: [String.t()],
  status: Wanda.Operations.Enums.Status.t(),
  step_failed: boolean(),
  targets: [Wanda.Operations.OperationTarget.t()],
  timer_ref: reference()
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

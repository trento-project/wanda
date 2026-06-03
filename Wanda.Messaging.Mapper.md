# `Wanda.Messaging.Mapper`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/messaging/mapper.ex#L4)

Maps domain structures to integration events.

# `from_execution_requested`

```elixir
@spec from_execution_requested(Trento.Checks.V1.ExecutionRequested.t()) :: %{
  execution_id: String.t(),
  group_id: String.t(),
  targets: [Wanda.Executions.Target.t()],
  target_type: String.t() | nil,
  env: %{required(String.t()) =&gt; boolean() | number() | String.t() | nil}
}
```

# `from_facts_gathererd`

```elixir
@spec from_facts_gathererd(Trento.Checks.V1.FactsGathered.t()) :: %{
  execution_id: String.t(),
  group_id: String.t(),
  agent_id: String.t(),
  facts_gathered: [Wanda.Executions.Fact.t() | Wanda.Executions.FactError.t()]
}
```

# `from_operation_requested`

```elixir
@spec from_operation_requested(Trento.Operations.V1.OperationRequested.t()) :: %{
  operation_id: String.t(),
  group_id: String.t(),
  operation_type: String.t(),
  targets: [Wanda.Operations.OperationTarget.t()]
}
```

# `from_operator_execution_completed`

```elixir
@spec from_operator_execution_completed(
  Trento.Operations.V1.OperatorExecutionCompleted.t()
) :: %{
  operation_id: String.t(),
  group_id: String.t(),
  step_number: number(),
  agent_id: String.t(),
  operator_result:
    Wanda.Operations.OperatorResult.t() | Wanda.Operations.OperatorError.t()
}
```

# `to_check_customization_applied`

```elixir
@spec to_check_customization_applied(
  String.t(),
  String.t(),
  String.t(),
  [Wanda.Catalog.CustomizedValue.t()]
) :: Trento.Checks.V1.CheckCustomizationApplied.t()
```

# `to_check_customization_reset`

```elixir
@spec to_check_customization_reset(
  String.t(),
  String.t(),
  String.t()
) :: Trento.Checks.V1.CheckCustomizationReset.t()
```

# `to_execution_completed`

# `to_execution_started`

```elixir
@spec to_execution_started(String.t(), String.t(), [Wanda.Executions.Target.t()]) ::
  Trento.Checks.V1.ExecutionStarted.t()
```

# `to_facts_gathering_requested`

# `to_operation_completed`

```elixir
@spec to_operation_completed(String.t(), String.t(), String.t(), atom()) ::
  Trento.Operations.V1.OperationCompleted.t()
```

# `to_operation_completed_with_errors`

```elixir
@spec to_operation_completed_with_errors(
  String.t(),
  String.t(),
  String.t(),
  :failed | :rolled_back | :timeout | :aborted,
  String.t(),
  %{required(Ecto.UUID.t()) =&gt; String.t()}
) :: Trento.Operations.V1.OperationCompleted.t()
```

# `to_operation_completed_with_failed_request`

```elixir
@spec to_operation_completed_with_failed_request(
  String.t(),
  String.t(),
  String.t(),
  :arguments_missing | :targets_missing | :already_running | :unknown
) :: Trento.Operations.V1.OperationCompleted.t()
```

# `to_operation_started`

```elixir
@spec to_operation_started(String.t(), String.t(), String.t(), [
  Wanda.Operations.OperationTarget.t()
]) ::
  Trento.Operations.V1.OperationStarted.t()
```

# `to_operator_execution_requested`

```elixir
@spec to_operator_execution_requested(String.t(), String.t(), number(), String.t(), [
  Wanda.Operations.OperationTarget.t()
]) :: Trento.Operations.V1.OperatorExecutionRequested.t()
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

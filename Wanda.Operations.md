# `Wanda.Operations`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/operations.ex#L4)

Operations are combined actions dispatched to different agents in order to apply
persistent changes on them.

# `abort_operation!`

```elixir
@spec abort_operation!(String.t()) :: Wanda.Operations.Operation.t()
```

Marks a previously started operation as aborted

# `complete_operation!`

```elixir
@spec complete_operation!(String.t(), Wanda.Operations.Enums.Result.t()) ::
  Wanda.Operations.Operation.t()
```

Marks a previously started operation as completed

# `create_operation!`

```elixir
@spec create_operation!(String.t(), String.t(), String.t(), [
  Wanda.Operations.OperationTarget.t()
]) ::
  Wanda.Operations.Operation.t()
```

Create a new operarion.

If the operation already exists, it will be returned.

# `enrich_operation!`

```elixir
@spec enrich_operation!(Wanda.Operations.Operation.t()) ::
  Wanda.Operations.Operation.t()
```

Enrich operation adding catalog_operation field

# `get_operation!`

```elixir
@spec get_operation!(String.t()) :: Wanda.Operations.Operation.t()
```

Get an operation by operation_id.

# `list_operations`

```elixir
@spec list_operations(map()) :: [Wanda.Operations.Operation.t()]
```

Get a paginated list of operations.

Can be filtered by group_id.

# `update_agent_reports!`

```elixir
@spec update_agent_reports!(String.t(), [Wanda.Operations.StepReport.t()]) ::
  Wanda.Operations.Operation.t()
```

Update agent_reports of an operation

---

*Consult [api-reference.md](api-reference.md) for complete listing*

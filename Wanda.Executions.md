# `Wanda.Executions`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/executions.ex#L4)

This module exposes functionalities to interact with the historycal log of executions.

# `complete_execution!`

```elixir
@spec complete_execution!(String.t(), Wanda.Executions.Result.t()) ::
  Wanda.Executions.Execution.t()
```

Marks a previously started execution as completed

# `count_executions`

```elixir
@spec count_executions(map()) :: non_neg_integer()
```

Counts executions in the database.

# `create_execution!`

```elixir
@spec create_execution!(String.t(), String.t(), [Wanda.Executions.Target.t()]) ::
  Wanda.Executions.Execution.t()
```

Create a new execution.

If the execution already exists, it will be returned.

# `get_execution!`

```elixir
@spec get_execution!(String.t()) :: Wanda.Executions.Execution.t()
```

Get an execution by execution_id.

# `get_last_execution_by_group_id!`

```elixir
@spec get_last_execution_by_group_id!(String.t()) :: Wanda.Executions.Execution.t()
```

Get the last execution of a group by group_id.

# `list_executions`

```elixir
@spec list_executions(map()) :: [Wanda.Executions.Execution.t()]
```

Get a paginated list of executions.

Can be filtered by group_id.

---

*Consult [api-reference.md](api-reference.md) for complete listing*

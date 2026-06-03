# `Wanda.Operations.ServerBehaviour`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/operations/server_behaviour.ex#L4)

Operation server API behaviour.

# `receive_operation_reports`

```elixir
@callback receive_operation_reports(
  operation_id :: String.t(),
  group_id :: String.t(),
  step_id :: number(),
  agent_id :: String.t(),
  operation_result :: Wanda.Operations.Enums.Result.t()
) :: :ok | {:error, any()}
```

# `start_operation`

```elixir
@callback start_operation(
  operation_id :: String.t(),
  group_id :: String.t(),
  operation :: Wanda.Operations.Catalog.Operation.t(),
  targets :: [Wanda.Operations.OperationTarget.t()]
) ::
  :ok
  | {:error, :arguments_missing}
  | {:error, :already_running}
  | {:error, :targets_missing}
```

# `start_operation`

```elixir
@callback start_operation(
  operation_id :: String.t(),
  group_id :: String.t(),
  operation :: Wanda.Operations.Catalog.Operation.t(),
  targets :: [Wanda.Operations.OperationTarget.t()],
  config :: Keyword.t()
) ::
  :ok
  | {:error, :arguments_missing}
  | {:error, :already_running}
  | {:error, :targets_missing}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

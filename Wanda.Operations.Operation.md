# `Wanda.Operations.Operation`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/operations/operation.ex#L4)

Schema of a persisted operation.

# `t`

```elixir
@type t() :: %Wanda.Operations.Operation{
  __meta__: term(),
  agent_reports: term(),
  catalog_operation: term(),
  catalog_operation_id: term(),
  completed_at: term(),
  group_id: term(),
  operation_id: term(),
  result: term(),
  started_at: term(),
  status: term(),
  targets: term(),
  timeout_at: term(),
  updated_at: term()
}
```

# `changeset`

```elixir
@spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

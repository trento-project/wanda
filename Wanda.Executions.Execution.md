# `Wanda.Executions.Execution`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/executions/execution.ex#L4)

Schema of a persisted execution.

# `t`

```elixir
@type t() :: %Wanda.Executions.Execution{
  __meta__: term(),
  completed_at: term(),
  execution_id: term(),
  group_id: term(),
  result: term(),
  started_at: term(),
  status: term(),
  targets: term()
}
```

# `changeset`

```elixir
@spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

# `Wanda.Operations.Catalog.Operation`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/operations/catalog/operation.ex#L4)

An operation is a set of actions executed step by step in agents to apply
permanent changes in them.

# `t`

```elixir
@type t() :: %Wanda.Operations.Catalog.Operation{
  description: String.t(),
  id: String.t(),
  name: String.t(),
  required_args: [String.t()],
  steps: [Wanda.Operations.Catalog.Step.t()]
}
```

# `total_timeout`

```elixir
@spec total_timeout(t()) :: non_neg_integer()
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

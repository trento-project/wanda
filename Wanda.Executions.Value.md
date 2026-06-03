# `Wanda.Executions.Value`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/executions/value.ex#L4)

Represents a Value used in expectation evaluation.
This value has been already determined given the conditions in check definition.

# `t`

```elixir
@type t() :: %Wanda.Executions.Value{
  customized: boolean(),
  name: String.t(),
  value: boolean() | number() | String.t()
}
```

# `from_resolved_value`

---

*Consult [api-reference.md](api-reference.md) for complete listing*

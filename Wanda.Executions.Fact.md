# `Wanda.Executions.Fact`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/executions/fact.ex#L4)

A fact is a piece of information that was gathered from a target.

# `t`

```elixir
@type t() :: %Wanda.Executions.Fact{
  check_id: String.t(),
  name: String.t(),
  value: boolean() | number() | String.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

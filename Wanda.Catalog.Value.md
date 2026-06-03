# `Wanda.Catalog.Value`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/catalog/value.ex#L4)

Represents a value.

# `t`

```elixir
@type t() :: %Wanda.Catalog.Value{
  conditions: [Wanda.Catalog.Condition.t()],
  customization_disabled: boolean(),
  default: boolean() | number() | String.t(),
  name: String.t()
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

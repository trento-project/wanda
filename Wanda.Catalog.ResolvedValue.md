# `Wanda.Catalog.ResolvedValue`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/catalog/resolved_value.ex#L4)

Represents a resolved check value as defined check specification.
It is based on the contextual environment.

# `t`

```elixir
@type t() :: %Wanda.Catalog.ResolvedValue{
  custom_value: value(),
  customized: boolean(),
  default_value: value(),
  name: String.t(),
  spec: Wanda.Catalog.Value.t()
}
```

# `value`

```elixir
@type value() :: boolean() | number() | String.t()
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

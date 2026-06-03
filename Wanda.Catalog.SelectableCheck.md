# `Wanda.Catalog.SelectableCheck`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/catalog/selectable_check.ex#L4)

Represents a check that is selectable for a given execution group given the context.

# `customized_value`

```elixir
@type customized_value() :: %{
  name: String.t(),
  customizable: true,
  default_value: boolean() | number() | String.t(),
  custom_value: boolean() | number() | String.t()
}
```

# `non_customized_value`

```elixir
@type non_customized_value() :: %{
  name: String.t(),
  customizable: boolean(),
  default_value: boolean() | number() | String.t()
}
```

# `t`

```elixir
@type t() :: %Wanda.Catalog.SelectableCheck{
  customizable: boolean(),
  customized: boolean(),
  description: String.t(),
  group: String.t(),
  id: String.t(),
  name: String.t(),
  values: [non_customized_value() | customized_value()]
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

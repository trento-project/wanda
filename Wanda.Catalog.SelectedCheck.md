# `Wanda.Catalog.SelectedCheck`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/catalog/selected_check.ex#L4)

Represents a selected check used during a check execution.

It carries information about the check specification and its available customizations.

# `t`

```elixir
@type t() :: %Wanda.Catalog.SelectedCheck{
  customizations: [Wanda.Catalog.CustomizedValue.t()],
  customized: boolean(),
  id: String.t(),
  spec: Wanda.Catalog.Check.t()
}
```

# `extract_specs`

```elixir
@spec extract_specs([t()]) :: [Wanda.Catalog.Check.t()]
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

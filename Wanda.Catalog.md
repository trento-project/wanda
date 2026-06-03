# `Wanda.Catalog`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/catalog.ex#L4)

Function to interact with the checks catalog.

# `get_catalog`

```elixir
@spec get_catalog(%{required(String.t()) =&gt; String.t()}) :: [Wanda.Catalog.Check.t()]
```

Get the checks catalog with all checks

# `get_catalog_for_group`

```elixir
@spec get_catalog_for_group(group_id :: String.t(), env :: map()) :: [
  Wanda.Catalog.SelectableCheck.t()
]
```

# `get_check`

```elixir
@spec get_check(String.t()) :: {:ok, Wanda.Catalog.Check.t()} | {:error, any()}
```

Get a check from the catalog.

# `get_checks`

```elixir
@spec get_checks([String.t()], map()) :: [Wanda.Catalog.Check.t()]
```

Get specific checks from the catalog.

# `to_selected_checks`

```elixir
@spec to_selected_checks([Wanda.Catalog.Check.t()], String.t()) :: [
  Wanda.Catalog.SelectedCheck.t()
]
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

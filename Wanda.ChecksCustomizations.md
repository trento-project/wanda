# `Wanda.ChecksCustomizations`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/checks_customizations.ex#L4)

Customization features.

# `custom_value`

```elixir
@type custom_value() :: %{name: String.t(), value: any()}
```

# `customize`

```elixir
@spec customize(
  check_id :: String.t(),
  group_id :: Ecto.UUID.t(),
  [custom_value()],
  opts :: Keyword.t()
) ::
  {:ok, Wanda.Catalog.CheckCustomization.t()}
  | {:error,
     :check_not_found | :check_not_customizable | :invalid_custom_values | any()}
```

# `get_customizations`

```elixir
@spec get_customizations(Ecto.UUID.t()) :: [Wanda.Catalog.CheckCustomization.t()]
```

# `reset_customization`

```elixir
@spec reset_customization(
  check_id :: String.t(),
  group_id :: Ecto.UUID.t(),
  opts :: Keyword.t()
) :: :ok | {:error, :customization_not_found}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

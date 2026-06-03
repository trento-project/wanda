# `Wanda.Operations.Catalog.Registry`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/operations/catalog/registry.ex#L4)

Operations registry where are available operations are listed

# `get_operation`

```elixir
@spec get_operation(String.t()) ::
  {:ok, Wanda.Operations.Catalog.Operation.t()} | {:error, :operation_not_found}
```

Get an operation by id

# `get_operation!`

```elixir
@spec get_operation!(String.t()) :: Wanda.Operations.Catalog.Operation.t()
```

Get an operation by id, erroring out if the entry doesn't exist

# `get_operations`

```elixir
@spec get_operations() :: [Wanda.Operations.Catalog.Operation.t()]
```

Get all operations

---

*Consult [api-reference.md](api-reference.md) for complete listing*

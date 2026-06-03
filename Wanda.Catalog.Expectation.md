# `Wanda.Catalog.Expectation`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/catalog/expectation.ex#L4)

Represents an expectation.

# `t`

```elixir
@type t() :: %Wanda.Catalog.Expectation{
  expression: String.t(),
  failure_message: String.t(),
  name: String.t(),
  type: Wanda.Catalog.Enums.ExpectType.t(),
  warning_message: String.t()
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

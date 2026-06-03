# `Wanda.Executions.ExpectationResult`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/executions/expectation_result.ex#L4)

Represents the result of an expectation.

# `t`

```elixir
@type t() :: %Wanda.Executions.ExpectationResult{
  failure_message: String.t() | nil,
  name: String.t(),
  result: boolean() | Wanda.Executions.Enums.Result.t(),
  type: Wanda.Catalog.Enums.ExpectType.t()
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

# `Wanda.Executions.ExpectationEvaluation`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/executions/expectation_evaluation.ex#L4)

Represents the evaluation of an expectation.

# `t`

```elixir
@type t() :: %Wanda.Executions.ExpectationEvaluation{
  failure_message: String.t() | nil,
  name: String.t(),
  return_value:
    number() | boolean() | String.t() | Wanda.Executions.Enums.Result.t(),
  type: Wanda.Catalog.Enums.ExpectType.t()
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

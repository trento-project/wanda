# `Wanda.Executions.ExpectationEvaluationError`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/executions/expectation_evaluation_error.ex#L4)

Represents an error occurred during the evaluation of an expectation.

# `t`

```elixir
@type t() :: %Wanda.Executions.ExpectationEvaluationError{
  message: String.t(),
  name: String.t(),
  type: Rhai.Error.t()
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

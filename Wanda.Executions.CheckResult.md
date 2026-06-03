# `Wanda.Executions.CheckResult`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/executions/check_result.ex#L4)

Represents the result of a check.

# `t`

```elixir
@type t() :: %Wanda.Executions.CheckResult{
  agents_check_results: [
    Wanda.Executions.AgentCheckResult.t() | Wanda.Executions.AgentCheckError.t()
  ],
  check_id: String.t(),
  customized: term(),
  expectation_results: [Wanda.Executions.ExpectationResult.t()],
  result: Wanda.Executions.Enums.Result.t()
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

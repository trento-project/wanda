# `Wanda.Executions.Result`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/executions/result.ex#L4)

Represents the result of an execution.

# `t`

```elixir
@type t() :: %Wanda.Executions.Result{
  check_results: [Wanda.Executions.CheckResult.t()],
  execution_id: String.t(),
  group_id: String.t(),
  result: Wanda.Executions.Enums.Result.t(),
  timeout: [String.t()]
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

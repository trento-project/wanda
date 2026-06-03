# `Wanda.Executions.AgentCheckResult`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/executions/agent_check_result.ex#L4)

Represents the result of a check on a specific agent.

# `t`

```elixir
@type t() :: %Wanda.Executions.AgentCheckResult{
  agent_id: String.t(),
  expectation_evaluations: [
    Wanda.Executions.ExpectationEvaluation.t()
    | Wanda.Executions.ExpectationEvaluationError.t()
  ],
  facts: [Wanda.Executions.Fact.t()],
  values: [Wanda.Executions.Value.t()]
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

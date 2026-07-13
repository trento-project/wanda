# `Wanda.Executions.ExcludedCheckResult`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/executions/excluded_check_result.ex#L4)

Represents a (check, agent) pair excluded by the check's `exclude` predicate.

# `t`

```elixir
@type t() :: %Wanda.Executions.ExcludedCheckResult{
  agent_id: String.t(),
  check_id: String.t(),
  exclude_expression: String.t() | nil,
  status: Wanda.Executions.Enums.AgentCheckStatus.t()
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

# `Wanda.Executions.AgentCheckError`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/executions/agent_check_error.ex#L4)

Represents the result of a check on a specific agent.

# `t`

```elixir
@type t() :: %Wanda.Executions.AgentCheckError{
  agent_id: String.t(),
  facts: [Wanda.Executions.Fact.t() | Wanda.Executions.FactError.t()] | nil,
  message: String.t(),
  type: :fact_gathering_error | :timeout
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

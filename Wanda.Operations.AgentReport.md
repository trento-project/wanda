# `Wanda.Operations.AgentReport`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/operations/agent_report.ex#L4)

Report of an executed operation from an individual agent

# `t`

```elixir
@type t() :: %Wanda.Operations.AgentReport{
  agent_id: String.t(),
  diff: map(),
  error_message: String.t(),
  result: Wanda.Operations.Enums.Result.t()
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

# `Wanda.Operations.OperatorResult`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/operations/operator_result.ex#L4)

Operator execution result retrieved from an agent.

# `diff`

```elixir
@type diff() :: %{before: any(), after: any()}
```

# `t`

```elixir
@type t() :: %Wanda.Operations.OperatorResult{
  diff: diff(),
  phase: Wanda.Operations.Enums.OperatorPhase.t()
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

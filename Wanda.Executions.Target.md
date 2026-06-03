# `Wanda.Executions.Target`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/executions/target.ex#L4)

Execution targets.

# `t`

```elixir
@type t() :: %Wanda.Executions.Target{agent_id: String.t(), checks: [String.t()]}
```

# `get_checks_from_targets`

```elixir
@spec get_checks_from_targets([t()]) :: [String.t()]
```

# `map_targets`

---

*Consult [api-reference.md](api-reference.md) for complete listing*

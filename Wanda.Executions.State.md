# `Wanda.Executions.State`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/executions/state.ex#L4)

State of an execution.

# `t`

```elixir
@type t() :: %Wanda.Executions.State{
  agents_gathered: [String.t()],
  checks: [Wanda.Catalog.SelectedCheck.t()],
  engine: Rhai.Engine.t(),
  env: %{required(String.t()) =&gt; boolean() | number() | String.t()},
  execution_id: String.t(),
  gathered_facts: map(),
  group_id: String.t(),
  targets: [Wanda.Executions.Target.t()],
  timeout: integer()
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

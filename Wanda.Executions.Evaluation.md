# `Wanda.Executions.Evaluation`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/executions/evaluation.ex#L4)

Evaluation functional core.

# `execute`

```elixir
@spec execute(
  String.t(),
  String.t(),
  [Wanda.Catalog.SelectedCheck.t()],
  map(),
  %{required(String.t()) =&gt; boolean() | number() | String.t()},
  [String.t()],
  Rhai.Engine.t()
) :: Wanda.Executions.Result.t()
```

# `has_some_fact_gathering_error?`

---

*Consult [api-reference.md](api-reference.md) for complete listing*

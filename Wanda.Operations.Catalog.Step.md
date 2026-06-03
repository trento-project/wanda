# `Wanda.Operations.Catalog.Step`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/operations/catalog/step.ex#L4)

A individual operation step running a single operator.
The predicate is a rhai execution that returns true/false
defining if the step needs to be executed in a certain agent.

The timeout must be defined in milliseconds

# `t`

```elixir
@type t() :: %Wanda.Operations.Catalog.Step{
  name: String.t(),
  operator: String.t(),
  predicate: String.t(),
  timeout: non_neg_integer()
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

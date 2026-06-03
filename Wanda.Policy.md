# `Wanda.Policy`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/policy.ex#L4)

Handles integration events.

# `handle_event`

```elixir
@spec handle_event(
  Trento.Checks.V1.ExecutionRequested.t()
  | Trento.Checks.V1.FactsGathered.t()
  | Trento.Operations.V1.OperationRequested.t()
  | Trento.Operations.V1.OperatorExecutionCompleted.t()
) :: :ok | {:error, any()}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

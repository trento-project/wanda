# `Wanda.Executions.FactsGathering`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/executions/facts_gathering.ex#L4)

Behaviour for the facts gathering source of a check execution.

An implementation is responsible for causing the facts for the given active
targets to eventually reach `Wanda.Executions.Server.receive_facts/4`.

The production implementation (`Wanda.Executions.FactsGathering.AMQP`)
dispatches a `FactsGatheringRequested` message to the agents; the demo
implementation (`Wanda.Executions.FactsGathering.Fake`) synthesizes the facts
locally. In both cases everything after dispatch (accumulation, evaluation,
exclusion injection and finalization) runs through the exact same `Server`
code path.

# `request_facts`

```elixir
@callback request_facts(
  execution_id :: String.t(),
  group_id :: String.t(),
  targets :: [Wanda.Executions.Target.t()],
  specs :: [Wanda.Catalog.Check.t()]
) :: :ok
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

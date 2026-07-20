# `Wanda.Executions.FactsGathering.AMQP`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/executions/facts_gathering/amqp.ex#L4)

Production facts gathering source: dispatches a `FactsGatheringRequested`
message to the agents over AMQP. The gathered facts flow back asynchronously
through `Wanda.Executions.Server.receive_facts/4`.

---

*Consult [api-reference.md](api-reference.md) for complete listing*

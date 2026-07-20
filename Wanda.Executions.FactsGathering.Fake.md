# `Wanda.Executions.FactsGathering.Fake`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/executions/facts_gathering/fake.ex#L4)

Demo/dev facts gathering source: it does not reach out to any agent. Instead
it synthesizes fake facts (see `Wanda.Executions.FakeGatheredFacts`) and feeds
them back into `Wanda.Executions.Server` through the same `receive_facts/4`
entry point the real agents use.

Because of this the execution flows through the exact same evaluation,
exclusion and finalization path as in production: `exclude` predicates are
honoured and `excluded` results are produced in demo just like with
the real server.

Facts are delivered asynchronously (after an optional `:sleep` delay) so the
server process is never blocked and the round-trip mimics real agents.

# `synthesize_facts`

```elixir
@spec synthesize_facts(Trento.Checks.V1.FactsGatheringRequested.t()) :: [
  %{agent_id: String.t(), facts: [Wanda.Executions.Fact.t()]}
]
```

Synthesizes fake facts for exactly the requests carried by a
`FactsGatheringRequested`, returning `[%{agent_id: String.t(), facts: [%Executions.Fact{}]}]`.

Kept public and pure so it can be asserted against the request it consumes.

---

*Consult [api-reference.md](api-reference.md) for complete listing*

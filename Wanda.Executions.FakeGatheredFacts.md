# `Wanda.Executions.FakeGatheredFacts`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/executions/facts_gathering/fake_gathered_facts.ex#L4)

Synthesizes the fake value of a single requested fact for the demo/dev facts
gathering source.

This module deliberately knows nothing about *which* facts to gather — that
decision belongs to `Wanda.Messaging.Mapper.to_facts_gathering_requested/4`,
the single source of truth shared with the production (AMQP) path. Here we only
answer "what value should this one `(check, agent, fact)` have", so the demo
path cannot drift from production on request contents.

# `fake_value`

```elixir
@spec fake_value(String.t(), String.t(), String.t()) :: term()
```

Returns the synthetic value for a single `(check, agent, fact)`, from the demo
facts yaml config, falling back to a default when not configured/readable.

---

*Consult [api-reference.md](api-reference.md) for complete listing*

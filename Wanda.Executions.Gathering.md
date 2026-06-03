# `Wanda.Executions.Gathering`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/executions/gathering.ex#L4)

Facts gathering functional core.

# `all_agents_sent_facts?`

```elixir
@spec all_agents_sent_facts?([String.t()], [Wanda.Executions.Target.t()]) :: boolean()
```

Check if all the agents have sent the facts

# `put_gathered_facts`

```elixir
@spec put_gathered_facts(map(), String.t(), [
  Wanda.Executions.Fact.t() | Wanda.Executions.FactError.t()
]) ::
  map()
```

Adds gathered facts of an agent.

# `put_gathering_timeouts`

```elixir
@spec put_gathering_timeouts(map(), [Wanda.Executions.Target.t()]) :: map()
```

Adds timeout data to gathered facts.

# `target?`

```elixir
@spec target?([Wanda.Executions.Target.t()], String.t()) :: boolean()
```

Check if an agent is a target of an execution

---

*Consult [api-reference.md](api-reference.md) for complete listing*

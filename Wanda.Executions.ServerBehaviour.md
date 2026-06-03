# `Wanda.Executions.ServerBehaviour`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/executions/server_behaviour.ex#L4)

Execution server API behaviour.

# `receive_facts`

```elixir
@callback receive_facts(
  execution_id :: String.t(),
  group_id :: String.t(),
  agent_id :: String.t(),
  facts :: [Wanda.Executions.Fact.t() | Wanda.Executions.FactError.t()]
) :: :ok | {:error, any()}
```

# `start_execution`

```elixir
@callback start_execution(
  execution_id :: String.t(),
  group_id :: String.t(),
  targets :: [Wanda.Executions.Target.t()],
  target_type :: String.t() | nil,
  env :: %{required(String.t()) =&gt; boolean() | number() | String.t()}
) :: :ok | {:error, :no_checks_selected} | {:error, :already_running}
```

# `start_execution`

```elixir
@callback start_execution(
  execution_id :: String.t(),
  group_id :: String.t(),
  targets :: [Wanda.Executions.Target.t()],
  target_type :: String.t() | nil,
  env :: %{required(String.t()) =&gt; boolean() | number() | String.t()},
  config :: Keyword.t()
) :: :ok | {:error, any()}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

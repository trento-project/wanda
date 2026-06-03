# `Wanda.Operations.OperationTarget`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/operations/operation_target.ex#L4)

An operation target defines an agent where the operation is executed
with arguments attached to this target, usually used to run the
operation step predicate

# `t`

```elixir
@type t() :: %Wanda.Operations.OperationTarget{
  agent_id: String.t(),
  arguments: %{required(String.t()) =&gt; boolean() | number() | String.t()}
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

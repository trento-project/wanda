# `Wanda.Users.User`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/users/user.ex#L4)

Represents the user performing actions in the system.

# `ability`

```elixir
@type ability() :: %{name: String.t(), resource: String.t()}
```

# `t`

```elixir
@type t() :: %Wanda.Users.User{abilities: [ability()], id: non_neg_integer()}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

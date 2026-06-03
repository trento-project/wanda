# `WandaWeb.Auth.Client.AuthClient`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda_web/auth/client/auth_client.ex#L4)

Client for interacting with the authentication server.

# `introspected_token`

```elixir
@type introspected_token() :: %{
  active: boolean(),
  sub: integer(),
  abilities: [%{name: String.t(), resource: String.t()}]
}
```

# `introspect_token`

```elixir
@callback introspect_token(token :: String.t()) ::
  {:ok, introspected_token()} | {:error, atom()}
```

# `introspect_token`

---

*Consult [api-reference.md](api-reference.md) for complete listing*

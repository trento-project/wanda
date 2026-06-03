# `WandaWeb.Auth.AuthPlug`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda_web/auth/auth_plug.ex#L4)

  Plug responsible for reading the Token from the authorization header and
  validating it.

  If the token is valid, the user_id is added to the private section of the
  connection.
  If the token is invalid, the connection is halted with a 401 response.

# `call`

  Read, validate and decode the Token from authorization header at each call

# `init`

---

*Consult [api-reference.md](api-reference.md) for complete listing*

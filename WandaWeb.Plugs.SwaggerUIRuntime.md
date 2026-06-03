# `WandaWeb.Plugs.SwaggerUIRuntime`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda_web/plugs/swaggerui_runtime.ex#L4)

  This Plug updates the original SwaggerUI configuration, by adding the
  configuration of oas_server_url (OAS_SERVER_URL in runtime) url subpath
  to the individual urls as prefix.
  This is needed if the OAS_SERVER_URL is given, most probably because
  wanda requests are coming from a proxy.

---

*Consult [api-reference.md](api-reference.md) for complete listing*

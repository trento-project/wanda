import Config

config :wanda, Wanda.Policy, execution_server_impl: Wanda.Executions.FakeServer

config :wanda, WandaWeb.Endpoint,
  check_origin: :conn,
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true

config :logger, level: :debug

config :cors_plug,
  origin: [
    "http://localhost:4000",
    "http://demo.trento-project.io",
    "https://demo.trento-project.io"
  ],
  allow_credentials: true

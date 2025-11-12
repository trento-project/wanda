import Config

config :wanda, Wanda.Policy,
  execution_server_impl: Wanda.Executions.FakeServer,
  operation_server_impl: Wanda.Operations.FakeServer

config :wanda, WandaWeb.Endpoint,
  check_origin: :conn,
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true

config :logger, level: :debug

config :wanda, Wanda.Executions.FakeGatheredFacts, demo_facts_config: "priv/demo/fake_facts.yaml"

config :wanda, Wanda.Operations.FakeReports,
  demo_operations_config: "priv/demo/fake_operations_reports.yaml"

import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :wanda, Wanda.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "wanda_test#{System.get_env("MIX_TEST_PARTITION")}",
  port: 5434,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :wanda, WandaWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4001],
  secret_key_base: "HipLWaSCDXUy5NYo9pu2D4cv9utZCdrmF00nHGN9maeDOxyricNSH7dUz+RNFLBY",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :wanda, Wanda.Catalog, catalog_paths: ["/usr/share/trento/checks", "test/fixtures/catalog"]

config :wanda, :messaging, adapter: Wanda.Messaging.Adapters.AMQP

config :wanda, Wanda.Messaging.Adapters.AMQP,
  consumer: [
    queue: "trento.test.checks.executions",
    exchange: "trento.test.checks",
    routing_key: "executions",
    prefetch_count: "10",
    connection: "amqp://wanda:wanda@localhost:5674",
    queue_options: [
      durable: false,
      auto_delete: true
    ],
    deadletter_queue_options: [
      durable: false,
      auto_delete: true
    ]
  ],
  publisher: [
    exchange: "trento.test.checks",
    connection: "amqp://wanda:wanda@localhost:5674"
  ],
  processor: GenRMQ.Processor.Mock

config :wanda,
  children: [Wanda.Messaging.Adapters.AMQP.Publisher, Wanda.Messaging.Adapters.AMQP.Consumer]

config :joken,
  access_token_signer: "s2ZdE+3+ke1USHEJ5O45KT364KiXPYaB9cJPdH3p60t8yT0nkLexLBNw8TFSzC7k"

config :wanda,
  jwt_authentication_enabled: false

config :wanda, Wanda.Executions.FakeGatheredFacts,
  demo_facts_config: "test/fixtures/demo/fake_facts_test.yaml"

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

config :wanda, Wanda.Catalog,
  catalog_paths: [
    "test/fixtures/catalog",
    "test/fixtures/non_scalar_values_catalog"
  ]

config :wanda, :messaging, adapter: Wanda.Messaging.Adapters.AMQP

amqp_connection =
  if System.get_env("USE_LOCAL_RABBIT_TLS") do
    "amqps://wanda:wanda@localhost:5676?certfile=container_fixtures/rabbitmq/certs/client_wanda.trento.local_certificate.pem&keyfile=container_fixtures/rabbitmq/certs/client_wanda.trento.local_key.pem&verify=verify_peer&cacertfile=container_fixtures/rabbitmq/certs/ca_certificate.pem"
  else
    "amqp://wanda:wanda@localhost:5674"
  end

config :wanda, Wanda.Messaging.Adapters.AMQP,
  checks: [
    consumer: [
      queue: "trento.test.checks.executions",
      exchange: "trento.test.checks",
      routing_key: "executions",
      prefetch_count: "10",
      connection: amqp_connection,
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
      connection: amqp_connection
    ],
    processor: GenRMQ.Processor.Mock
  ],
  operations: [
    consumer: [
      queue: "trento.test.operations.requests",
      exchange: "trento.test.operations",
      routing_key: "requests",
      prefetch_count: "10",
      connection: amqp_connection,
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
      exchange: "trento.test.operations",
      connection: amqp_connection
    ],
    processor: GenRMQ.Processor.Mock
  ],
  catalog: [
    publisher: [
      exchange: "trento.test.catalog",
      connection: amqp_connection
    ]
  ]

config :wanda,
  children: [
    Wanda.Executions.Messaging.Publisher,
    Wanda.Executions.Messaging.Consumer,
    Wanda.Operations.Messaging.Publisher,
    Wanda.Operations.Messaging.Consumer
  ]

config :wanda,
  token_authentication_enabled: false

config :wanda, Wanda.Executions.FakeGatheredFacts,
  demo_facts_config: "test/fixtures/demo/fake_facts_test.yaml"

config :exvcr, global_mock: true

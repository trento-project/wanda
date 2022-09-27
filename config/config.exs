import Config

config :wanda, Wanda.Messaging.Publisher, adapter: Wanda.Messaging.Adapters.AMQP

config :wanda,
  children: [Wanda.Messaging.Adapters.AMQP.Publisher, Wanda.Messaging.Adapters.AMQP.Consumer]

config :wanda, :messaging, adapter: Wanda.Messaging.Adapters.AMQP

config :wanda, Wanda.Messaging.Adapters.AMQP,
  consumer: [
    queue: "trento.checks.executions",
    exchange: "trento.checks",
    routing_key: "executions",
    prefetch_count: "10",
    connection: "amqp://wanda:wanda@localhost:5672"
  ],
  publisher: [
    exchange: "trento.checks",
    connection: "amqp://wanda:wanda@localhost:5672"
  ]

config :wanda, Wanda.Catalog, catalog_path: "priv/catalog"

config :wanda, Wanda.Policy, execution_impl: Wanda.Execution

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

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

# Phoenix configuration

config :wanda,
  ecto_repos: [Wanda.Repo]

# Configures the endpoint
config :wanda, WandaWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: WandaWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Wanda.PubSub,
  live_view: [signing_salt: "j6kcshS4"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

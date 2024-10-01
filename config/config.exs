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
  ],
  processor: Wanda.Messaging.Adapters.AMQP.Processor

config :wanda, Wanda.Catalog, catalog_paths: ["priv/catalog"]

config :wanda, Wanda.Policy, execution_server_impl: Wanda.Executions.Server

# Phoenix configuration

config :wanda,
  ecto_repos: [Wanda.Repo]

# Configures the endpoint
config :wanda, WandaWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: WandaWeb.ErrorJSON],
    layout: false
  ],
  live_view: [signing_salt: "j6kcshS4"]

config :cors_plug,
  origin: [System.get_env("CORS_ORIGIN", "http://localhost:4000")]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Disable rustler precompiled NIFs
config :rustler_precompiled, :force_build, rhai_rustler: true

config :wanda,
  cors_enabled: true,
  jwt_authentication_enabled: true

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

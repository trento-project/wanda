import Config

config :wanda, Wanda.Messaging.Publisher, adapter: Wanda.Messaging.Adapters.AMQP

config :wanda,
  children: [
    Wanda.Executions.Messaging.Publisher,
    Wanda.Executions.Messaging.Consumer,
    Wanda.Operations.Messaging.Publisher,
    Wanda.Operations.Messaging.Consumer,
    Wanda.Catalog.Messaging.Publisher
  ]

config :wanda, :messaging, adapter: Wanda.Messaging.Adapters.AMQP

amqp_connection = "amqp://wanda:wanda@localhost:5672"

config :wanda, Wanda.Messaging.Adapters.AMQP,
  checks: [
    consumer: [
      queue: "trento.checks.executions",
      exchange: "trento.checks",
      routing_key: "executions",
      prefetch_count: "10",
      connection: amqp_connection
    ],
    publisher: [
      exchange: "trento.checks",
      connection: amqp_connection
    ],
    processor: Wanda.Messaging.Adapters.AMQP.Processor
  ],
  operations: [
    consumer: [
      queue: "trento.operations.requests",
      exchange: "trento.operations",
      routing_key: "requests",
      prefetch_count: "10",
      connection: amqp_connection
    ],
    publisher: [
      exchange: "trento.operations",
      connection: amqp_connection
    ],
    processor: Wanda.Messaging.Adapters.AMQP.Processor
  ],
  catalog: [
    publisher: [
      exchange: "trento.catalog",
      connection: amqp_connection
    ]
  ]

config :wanda, Wanda.Catalog, catalog_paths: ["priv/catalog"]

config :wanda, Wanda.Policy,
  execution_server_impl: Wanda.Executions.Server,
  operation_server_impl: Wanda.Operations.Server

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
  token_authentication_enabled: true,
  operations_enabled: true,
  date_service: Wanda.Support.DateService,
  oas_server_url: nil

config :bodyguard,
  default_error: :forbidden

config :wanda, :auth_server, url: "http://localhost:4000"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

# dummy change

import Config

config :wanda, Wanda.Messaging.ProcessCache,
  # When using :shards as backend
  # backend: :shards,
  # GC interval for pushing new generation: 12 hrs
  gc_interval: :timer.hours(12),
  # Max 1 million entries in cache
  max_size: 1_000_000,
  # Max 2 GB of memory
  allocated_memory: 2_000_000_000,
  # GC min timeout: 10 sec
  gc_cleanup_min_timeout: :timer.seconds(10),
  # GC max timeout: 10 min
  gc_cleanup_max_timeout: :timer.minutes(10)

config :wanda, Wanda.Messaging.Publisher, adapter: Wanda.Messaging.Adapters.AMQP

config :wanda,
  children: [
    Wanda.Messaging.Adapters.AMQP.Publisher,
    Wanda.Messaging.Adapters.AMQP.Consumer,
    Wanda.Messaging.ProcessCache
  ]

config :wanda, :messaging,
  adapter: Wanda.Messaging.Adapters.AMQP,
  amqp: [
    consumer: [
      queue: "events_wanda",
      exchange: "events",
      routing_key: "checks.executions.*",
      prefetch_count: "10",
      connection: "amqp://wanda:wanda@localhost:5672"
    ],
    publisher: [
      exchange: "events",
      connection: "amqp://wanda:wanda@localhost:5672"
    ]
  ]

config :wanda, Wanda.Catalog, catalog_path: "priv/catalog"

config :wanda, Wanda.Policy, execution_impl: Wanda.Execution

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

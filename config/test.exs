import Config

config :wanda, Wanda.Catalog, catalog_path: "test/fixtures/catalog"

config :wanda, :messaging,
  adapter: Wanda.Messaging.Adapters.AMQP,
  amqp: [
    consumer: [
      queue: "trento.test.checks.executions",
      exchange: "trento.test.checks",
      routing_key: "executions",
      prefetch_count: "10",
      connection: "amqp://wanda:wanda@localhost:5672",
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
      connection: "amqp://wanda:wanda@localhost:5672"
    ]
  ]

config :wanda,
  children: [Wanda.Messaging.Adapters.AMQP.Publisher, Wanda.Messaging.Adapters.AMQP.Consumer]

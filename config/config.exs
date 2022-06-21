import Config

config :wanda, Wanda.Facts.Messenger, adapter: Wanda.Facts.Messenger.RabbitMQ

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

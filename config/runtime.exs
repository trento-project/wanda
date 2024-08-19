import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.
if config_env() in [:prod, :demo] do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6"), do: [:inet6], else: []

  config :wanda, Wanda.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  port = String.to_integer(System.get_env("PORT") || "4000")

  config :wanda, WandaWeb.Endpoint,
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  amqp_url =
    System.get_env("AMQP_URL") ||
      raise """
      environment variable AMQP_URL is missing.
      For example: amqp://USER:PASSWORD@HOST
      """

  config :wanda, Wanda.Messaging.Adapters.AMQP,
    consumer: [
      connection: amqp_url
    ],
    publisher: [
      connection: amqp_url
    ]

  cors_enabled = System.get_env("CORS_ENABLED", "true") == "true"

  config :wanda,
    cors_enabled: cors_enabled

  if cors_enabled do
    cors_origin =
      System.get_env("CORS_ORIGIN") ||
        raise """
        environment variable CORS_ORIGIN is missing.
        For example: http://your-domain.com
        """

    config :cors_plug,
      origin: [cors_origin]
  end

  jwt_authentication_enabled = System.get_env("JWT_AUTHENTICATION_ENABLED", "true") == "true"

  config :wanda,
    jwt_authentication_enabled: jwt_authentication_enabled

  if jwt_authentication_enabled do
    config :joken,
      access_token_signer:
        System.get_env("ACCESS_TOKEN_ENC_SECRET") ||
          raise("""
          environment variable ACCESS_TOKEN_ENC_SECRET is missing.
          You can generate one by calling: mix phx.gen.secret
          """)
  end

  # Update catalog path to the current application dir during runtime
  config :wanda, Wanda.Catalog,
    catalog_paths: [
      "/usr/share/trento/checks",
      System.get_env(
        "CATALOG_PATH",
        Application.app_dir(
          :wanda,
          "priv/catalog"
        )
      )
    ]
end

if config_env() === :demo do
  config :wanda, Wanda.Executions.FakeGatheredFacts,
    demo_facts_config:
      System.get_env(
        "DEMO_FAKE_FACTS",
        Application.app_dir(
          :wanda,
          "priv/demo/fake_facts.yaml"
        )
      )
end

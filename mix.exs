defmodule Wanda.MixProject do
  use Mix.Project

  def project do
    [
      app: :wanda,
      version: "0.1.0",
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [plt_add_apps: [:ex_unit]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Wanda.Application, []}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test),
    do: [
      "lib",
      "test/support"
    ]

  defp elixirc_paths(_), do: ["lib"]
  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:rhai_rustler, "~> 0.1.1"},
      {:gen_rmq, "~> 4.0"},
      # this is pinned since the 3.1.0 version requires OTP 23.2
      # overrides gen_rmq dependency
      {:credentials_obfuscation, "3.0.0", override: true},
      {:jason, "~> 1.3"},
      {:yaml_elixir, "~> 2.9"},
      {:trento_contracts, github: "trento-project/contracts", ref: "01db6a7", sparse: "elixir"},
      # test deps
      {:ex_doc, "~> 0.29", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:mox, "~> 1.0", only: :test},
      {:ex_machina, "~> 2.7.0", only: :test},
      {:faker, "~> 0.17", only: :test},
      # phoenix deps
      {:phoenix, "~> 1.6.12"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:plug_cowboy, "~> 2.5"},
      {:open_api_spex, "~> 3.13"},
      {:cors_plug, "~> 3.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end

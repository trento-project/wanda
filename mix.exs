defmodule Wanda.MixProject do
  use Mix.Project

  def project do
    [
      app: :wanda,
      version: "0.1.0",
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
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
      {:abacus, "~> 0.4.2"},
      {:elixir_uuid, "~> 1.2"},
      {:gen_rmq, "~> 4.0"},
      {:jason, "~> 1.3"},
      {:yaml_elixir, "~> 2.9"},
      {:cloudevents, "~> 0.4.0"},
      {:ex_json_schema, "~> 0.9.1"},
      # test deps
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:mox, "~> 1.0", only: :test},
      {:ex_machina, "~> 2.7.0", only: :test},
      {:faker, "~> 0.17", only: :test},
      {:nebulex, "~> 2.4"},
    ]
  end
end

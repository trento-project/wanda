defmodule Wanda.MixProject do
  use Mix.Project

  @source_url "https://github.com/trento-project/wanda"

  def project do
    [
      app: :wanda,
      version: get_version(),
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      name: "Wanda",
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.github": :test
      ],
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

  defp docs do
    [
      main: "readme",
      logo: "priv/static/images/trento.svg",
      extra_section: "GUIDES",
      source_url: @source_url,
      assets: "guides/assets/",
      extras: extras(),
      groups_for_extras: groups_for_extras(),
      groups_for_modules: groups_for_modules(),
      nest_modules_by_prefix: [
        Wanda.Catalog,
        Wanda.Executions,
        Wanda.Messaging,
        WandaWeb
      ]
    ]
  end

  defp extras() do
    [
      "README.md",
      "CHANGELOG.md",
      "CONTRIBUTING.md",
      "guides/specification.md",
      "guides/expression_language.md",
      "guides/gatherers.md",
      "guides/rhai_expressions_cheat_sheet.cheatmd",
      "guides/development/hack_on_wanda.md",
      "guides/development/demo.md"
    ]
  end

  defp groups_for_extras do
    [
      "Checks development": [
        "guides/specification.md",
        "guides/expression_language.md",
        "guides/gatherers.md"
      ],
      "Hack on Wanda": ["guides/development/hack_on_wanda.md", "guides/development/demo.md"]
    ]
  end

  defp groups_for_modules do
    [
      Executions: [
        ~r/Wanda.Executions*/
      ],
      Catalog: [
        ~r/Wanda.Catalog*/
      ],
      Messaging: [
        ~r/Wanda.Messaging*/
      ],
      Web: [
        ~r/WandaWeb*/
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test),
    do: [
      "lib",
      "test/support",
      "demo"
    ]

  defp elixirc_paths(:demo),
    do: [
      "test/support/factory.ex",
      "demo",
      "lib"
    ]

  defp elixirc_paths(_), do: ["lib"]
  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:rhai_rustler, "~> 1.2.0"},
      {:rustler, ">= 0.0.0", optional: true},
      {:jason, "~> 1.3"},
      # see: https://github.com/pma/amqp/issues/231#issuecomment-2445049446
      {:ranch, "~> 2.2.0", override: true},
      {:gen_rmq, github: "cdimonaco/gen_rmq", ref: "v5.0.1"},
      {:yaml_elixir, "~> 2.9"},
      {:trento_contracts,
       github: "trento-project/contracts",
       sparse: "elixir",
       ref: "d5af3530960f0b97efbf0525be7a385457130d62"},
      {:unplug, "~> 1.1.0"},
      # test deps
      {:ex_doc, "~> 0.29", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:mox, "~> 1.0", only: :test},
      {:ex_machina, "~> 2.8.0", only: [:demo, :test]},
      {:faker, "~> 0.17", only: [:demo, :test]},
      {:excoveralls, "~> 0.10", only: :test},
      # phoenix deps
      {:phoenix, "~> 1.7"},
      {:phoenix_view, "~> 2.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:plug_cowboy, "~> 2.5"},
      {:open_api_spex, "~> 3.21.0"},
      {:cors_plug, "~> 3.0"},
      {:joken, "~> 2.6.0"},
      # required overrides to upgrade to elixir 1.15.7 and erlang otp 26
      # https://stackoverflow.com/questions/76562092/hi-i-had-created-elixir-project-with-phoenix-framework-there-is-yaml-file-when
      {:ecto, "~> 3.10", override: true},
      {:bodyguard, "~> 2.4"}
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
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "coveralls.github": ["ecto.create --quiet", "ecto.migrate --quiet", "coveralls.github"]
    ]
  end

  defp get_version do
    case System.get_env("VERSION", "") do
      "" -> get_version_from_file()
      version -> version
    end
  end

  defp get_version_from_file do
    File.cwd!() |> Path.join("VERSION") |> File.read!() |> String.trim()
  end
end

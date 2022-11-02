defmodule Wanda.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        # Start the Ecto repository
        Wanda.Repo,
        # Start the Telemetry supervisor
        WandaWeb.Telemetry,
        # Start the Endpoint (http/https)
        WandaWeb.Endpoint,
        # Start a worker by calling: Wanda.Worker.start_link(arg)
        # {Wanda.Worker, arg}
        {DynamicSupervisor, strategy: :one_for_one, name: Wanda.Executions.Supervisor}
      ] ++ Application.get_env(:wanda, :children, [])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Wanda.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WandaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

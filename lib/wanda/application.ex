defmodule Wanda.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @registry :execution_registry

  @impl true
  def start(_type, _args) do
    children = [
      Wanda.ExecutionSupervisor,
      {Registry, [keys: :unique, name: @registry]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Wanda.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

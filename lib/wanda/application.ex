defmodule Wanda.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        {DynamicSupervisor, strategy: :one_for_one, name: Wanda.Execution.Supervisor}
      ] ++ Application.get_env(:wanda, :children, [])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Wanda.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

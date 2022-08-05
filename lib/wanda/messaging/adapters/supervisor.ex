defmodule Wanda.Messaging.Supervisor do
  @moduledoc """
  Messaging supervisor.
  """

  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    Supervisor.init(adapter().child_spec(), strategy: :one_for_one)
  end

  def adapter, do: Application.fetch_env!(:wanda, :messaging)[:adapter]
end

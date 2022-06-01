defmodule Wanda.ExecutionServer do
  use GenServer
  require Logger

  @registry :execution_registry
  @initial_state %{players: []}

  defstruct [
    agents_id: [],
    checks_id: [],
  ]

  ## GenServer API

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  def log_state(process_name) do
    process_name |> via_tuple() |> GenServer.call(:log_state)
  end

  def add_player(process_name, player_name) do
    process_name |> via_tuple() |> GenServer.call({:add_player, player_name})
  end

  @doc """
  This function will be called by the supervisor to retrieve the specification
  of the child process.The child process is configured to restart only if it
  terminates abnormally.
  """
  def child_spec(process_name) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [process_name]},
      restart: :transient
    }
  end

  def stop(process_name, stop_reason) do
    # Given the :transient option in the child spec, the GenServer will restart
    # if any reason other than `:normal` is given.
    process_name |> via_tuple() |> GenServer.stop(stop_reason)
  end

  ## GenServer Callbacks

  @impl true
  def init(name) do
    Logger.info("Starting process #{name}")
    {:ok, @initial_state}
  end

  @impl true
  def handle_call(:log_state, _from, state) do
    {:reply, "State: #{inspect(state)}", state}
  end

  @impl true
  def handle_call({:add_player, new_player}, _from, state) do
    new_state =
      Map.update!(state, :players, fn existing_players ->
        [new_player | existing_players]
      end)

    {:reply, :player_added, new_state}
  end

  ## Private Functions
  defp via_tuple(name),
    do: {:via, Registry, {@registry, name}}
end

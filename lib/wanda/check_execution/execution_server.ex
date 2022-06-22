defmodule Wanda.ExecutionServer do
  @moduledoc """
  Represents the execution of the CheckSelection(s) on the target nodes/agents of a cluster
  Orchestrates facts gathering on the targets - issuing execution and receiving back facts - and following check evaluations
  """

  use GenServer
  require Logger

  @registry :execution_registry

  defmodule CheckSelection do
    defstruct [
      ## agent_id?
      :host_id,
      checks: []
    ]

    @type t :: %__MODULE__{
            host_id: String.t(),
            checks: [String.t()]
          }
  end

  defstruct [
    :execution_id,
    :cluster_id,

    # :extra, # this might contain information about the provider or
    # A pacemaker cluster is an specific workload type for which configuration values rely not just on the platform (Azure, AWS, GCP, etc)
    # but also on other factors that should be all detected automatically by Trento. For instance:
    # HA Scenario (HANA scale-up, HANA scale-out, ENSA2, etc),
    # Cluster Type (2 node cluster, 2+ node cluster) or
    # Fencing Type (SBD, agent based).

    # The only distinction that Trento cannot do automatically is the one between HANA scale-up performance optimized and HANA scale-up cost optimized.
    # That one must be provided manually by the user in the corresponding host details view or pacemaker cluster details view.
    # Page https://confluence.suse.com/display/TRNT/Trento+Checks+ER+Model is a proposal on what the data model for pacemaker cluster could look like.

    # Other workload types that will be also under consideration are specific saptune solutions (e.g. HANA or NetWeaver application server).
    selections: [],
    gathered_facts: 0
  ]

  @type t :: %__MODULE__{
          execution_id: String.t(),
          cluster_id: String.t(),
          # temporary, this needs to actually keep track of the facts
          gathered_facts: non_neg_integer(),
          selections: [CheckSelection.t()]
        }

  ## GenServer API

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  def log_state(process_name) do
    process_name |> via_tuple() |> GenServer.call(:log_state)
  end

  def start_execution(process_name, %Wanda.CheckExecution{} = execution) do
    process_name |> via_tuple() |> GenServer.cast({:start_execution, execution})
  end

  # %{s

  def gather_facts(process_name, check_facts) do
    process_name |> via_tuple() |> GenServer.cast({:gather_facts, check_facts})
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
    {:ok, %__MODULE__{}}
  end

  @impl true
  def handle_call(:log_state, _from, state) do
    {:reply, "State: #{inspect(state)}", state}
  end

  @impl true
  def handle_cast(
        {:start_execution,
         %Wanda.CheckExecution{
           execution_id: execution_id,
           cluster_id: cluster_id,
           targets_selections: targets_selections
         }},
        state
      ) do
    targets_selections
    |> ignore_empty_selections()
    |> start_facts_gathering(execution_id)

    # the 500ms timeout would be the timeout to complete the execution
    # THE WHOLE EXECUTION: FACTS GATHERING AND CHECK EVALUATION

    # {:noreply, new_state, 5000}

    {:noreply,
     %__MODULE__{
       state
       | execution_id: execution_id,
         cluster_id: cluster_id,
         selections: targets_selections
     }}
  end

  defp ignore_empty_selections(selection) do
    Enum.reject(selection, fn %{checks: checks} -> checks == [] end)
  end

  defp start_facts_gathering(selection, execution_id) do
    selection
    |> Enum.each(fn %{host_id: agent, checks: checks} ->
      # this?
      # start_facts_gathering(execution_id, host_id, checks)
      # or this?
      Wanda.Facts.Gathering.start(execution_id, agent, checks)
    end)
  end

  @impl true
  def handle_cast(
        {:gather_facts,
         %{
           execution_id: execution_id,
           host_id: host_id,
           check: check,
           gathered_facts: gathered_facts
         } = check_facts},
        %Wanda.ExecutionServer{selections: selections, gathered_facts: gf} = state
      ) do
    # gf is just a temporary hack to keep count of gathered facts
    gf = gf + 1
    all_checks = Enum.flat_map(selections, fn %{checks: checks} -> checks end)

    case length(all_checks) do
      ^gf ->
        Logger.info(
          "Execution completed, remaining #{Registry.count(:execution_registry) - 1} processes"
        )

        {:stop, :normal, {:something}}

      _ ->
        {:noreply, %Wanda.ExecutionServer{state | execution_id: execution_id, gathered_facts: gf}}
    end
  end

  def handle_cast({:start_facts_gathering, {execution_id, host_id, checks}}, state) do
    Wanda.Facts.Gathering.start(execution_id, host_id, checks)
    {:noreply, state}
  end

  def start_facts_gathering(execution_id, host_id, checks) do
    execution_id
    |> via_tuple()
    |> GenServer.cast({:start_facts_gathering, {execution_id, host_id, checks}})
  end

  # Following handle_info/2 were implemented after noticing the following
  # [error] Wanda.ExecutionServer #PID<0.208.0> received unexpected message in handle_info/2: {#Reference<0.2608775059.879296517.242597>, :ok}
  # [error] Wanda.ExecutionServer #PID<0.208.0> received unexpected message in handle_info/2: {:DOWN, #Reference<0.2608775059.879296517.242597>, :process, #PID<0.211.0>, :normal}
  @impl true
  def handle_info({_pid, _payload}, state),
    do: {:noreply, state}

  @impl true
  def handle_info({:DOWN, _ref, :process, _pid, :normal}, state),
    do: {:noreply, state}

  @impl true
  def handle_info(:timeout, %{execution_id: execution_id} = state) do
    IO.puts("execution #{execution_id} timed out")

    # What should happen on timeout? Stop the execution?
    # Wanda.ExecutionServer.stop(execution_id, :normal)

    {:noreply, state}
  end

  ## Private Functions
  defp via_tuple(name),
    do: {:via, Registry, {@registry, name}}
end

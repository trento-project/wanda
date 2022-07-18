defmodule Wanda.ExecutionSupervisor do
  @moduledoc nil

  use DynamicSupervisor

  alias Wanda.Execution

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_execution(execution_id, group_id, targets) do
    child_spec = %{
      id: {Execution, execution_id},
      start: {Execution, :start_link, [execution_id, group_id, targets]},
      restart: :temporary,
      type: :worker
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @impl true
  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end

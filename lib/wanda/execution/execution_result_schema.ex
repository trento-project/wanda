defmodule Wanda.Execution.ExecutionResult do
  @moduledoc """
  Represents a storable ExecutionResult, available after check evaluation
  """

  use Ecto.Schema

  @type t :: %__MODULE__{}

  @primary_key false
  schema "execution_results" do
    field(:execution_id, Ecto.UUID, primary_key: true)
    field(:group_id, Ecto.UUID)
    field(:payload, :map)

    timestamps(type: :utc_datetime_usec)
  end
end

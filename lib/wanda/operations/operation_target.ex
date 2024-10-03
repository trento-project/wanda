defmodule Wanda.Operations.OperationTarget do
  @moduledoc """
  """

  defstruct [
    :agent_id,
    arguments: %{}
  ]

  @type t :: %__MODULE__{
          agent_id: String.t(),
          arguments: %{String.t() => boolean() | number() | String.t()}
        }
end

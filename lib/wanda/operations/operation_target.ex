defmodule Wanda.Operations.OperationTarget do
  @moduledoc """
  An operation target defines an agent where the operation is executed
  with arguments attached to this target, usually used to run the
  operation step predicate
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

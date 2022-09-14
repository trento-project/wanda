defmodule Wanda.Execution.AgentCheckError do
  @moduledoc """
  Represents the result of a check on a specific agent.
  """

  @derive Jason.Encoder
  defstruct [
    :agent_id,
    :error,
    :message
  ]

  @type t :: %__MODULE__{
          agent_id: String.t(),
          error: atom(),
          message: String.t()
        }
end

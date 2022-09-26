defmodule Wanda.Execution.AgentCheckError do
  @moduledoc """
  Represents the result of a check on a specific agent.
  """

  @derive Jason.Encoder
  defstruct [
    :agent_id,
    :type,
    :message
  ]

  @type t :: %__MODULE__{
          agent_id: String.t(),
          type: :timeout,
          message: String.t()
        }
end

defmodule Wanda.Executions.AgentCheckError do
  @moduledoc """
  Represents the result of a check on a specific agent.
  """

  alias Wanda.Executions.{
    Fact,
    FactError
  }

  @derive Jason.Encoder
  defstruct [
    :agent_id,
    :facts,
    :type,
    :message
  ]

  @type t :: %__MODULE__{
          agent_id: String.t(),
          facts: [Fact.t() | FactError.t()],
          type: :timeout,
          message: String.t()
        }
end

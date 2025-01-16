defmodule Wanda.Operations.AgentReport do
  @moduledoc """
  Report of an executed operation from an individual agent
  """

  require Wanda.Operations.Enums.Result, as: Result

  defstruct [
    :agent_id,
    :result
  ]

  @type t :: %__MODULE__{
          agent_id: String.t(),
          result: Result.t()
        }
end

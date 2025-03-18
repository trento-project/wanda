defmodule Wanda.Operations.AgentReport do
  @moduledoc """
  Report of an executed operation from an individual agent
  """

  require Wanda.Operations.Enums.Result, as: Result

  @derive Jason.Encoder
  defstruct [
    :agent_id,
    :result,
    :diff,
    :error_message
  ]

  @type t :: %__MODULE__{
          agent_id: String.t(),
          result: Result.t(),
          diff: map(),
          error_message: String.t()
        }
end

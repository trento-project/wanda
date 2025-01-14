defmodule Wanda.Operations.AgentReport do
  @moduledoc """
  Report of an executed operation from an individual agent
  """

  defstruct [
    :agent_id,
    :result
  ]

  @type t :: %__MODULE__{
          agent_id: String.t(),
          result: :updated | :not_updated | :failed | :rolled_back | :skipped | :not_executed
        }
end

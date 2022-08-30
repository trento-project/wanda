defmodule Wanda.Execution.FactsRequest do
  @moduledoc """
  Represents a request to gather Facts for a given Execution.
  """

  alias Wanda.Execution.AgentFacts

  @derive Jason.Encoder
  defstruct [:execution_id, :group_id, :targets, :facts]

  @type t :: %__MODULE__{
          execution_id: String.t(),
          group_id: String.t(),
          targets: [String.t()],
          facts: [AgentFacts.t()]
        }
end

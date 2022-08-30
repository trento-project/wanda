defmodule Wanda.Execution.AgentFacts do
  @moduledoc """
  Represents the Facts to be gathered on a given agent
  """

  alias Wanda.Catalog.Fact

  @derive Jason.Encoder
  defstruct [:agent_id, :facts]

  @type t :: %__MODULE__{
          agent_id: String.t(),
          facts: [Fact.t()]
        }
end

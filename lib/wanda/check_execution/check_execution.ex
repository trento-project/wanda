defmodule Wanda.CheckExecution do
  @moduledoc """
  Represents a CheckExectution that can be Started
  """

  defmodule CheckSelection do
    @moduledoc """
    Represents the SelectedChecks of a Host/Agent
    """

    defstruct [
      ## agent_id?
      :host_id,
      checks: []
    ]

    @type t :: %__MODULE__{
            host_id: String.t(),
            checks: [String.t()]
          }
  end

  defstruct [
    :execution_id,
    :cluster_id,
    targets_selections: []
  ]

  @type t :: %__MODULE__{
          execution_id: String.t(),
          cluster_id: String.t(),
          targets_selections: [CheckSelection.t()]
        }
end

defmodule Wanda.Operations.OperatorError do
  @moduledoc """
  Operator execution result with an error retrieved from an agent.
  """

  require Wanda.Operations.Enums.OperatorPhase, as: OperatorPhase

  @derive Jason.Encoder
  defstruct [
    :phase,
    :message
  ]

  @type t :: %__MODULE__{
          phase: OperatorPhase.t(),
          message: String.t()
        }
end

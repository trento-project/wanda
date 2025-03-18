defmodule Wanda.Operations.OperatorResult do
  @moduledoc """
  Operator execution result retrieved from an agent.
  """

  require Wanda.Operations.Enums.OperatorPhase, as: OperatorPhase

  @type diff :: %{
          before: any(),
          after: any()
        }

  @derive Jason.Encoder
  defstruct [
    :phase,
    :diff
  ]

  @type t :: %__MODULE__{
          phase: OperatorPhase.t(),
          diff: diff()
        }
end

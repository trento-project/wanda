defmodule Wanda.Operations.OperationReportError do
  @moduledoc """
  """

  @derive Jason.Encoder
  defstruct [
    :message,
    :error_phase
  ]

  @type t :: %__MODULE__{
          message: String.t(),
          error_phase: :plan | :commit | :verify | :rollback
        }
end

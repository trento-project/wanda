defmodule Wanda.Operations.OperationErrorDetails do
  @moduledoc """
  Operation error details.

  target_errors containts the error message for all the targets with an error
  during the operator execution for the last step.
  """

  @derive Jason.Encoder
  defstruct [
    :step,
    :target_errors
  ]

  @type t :: %__MODULE__{
          step: String.t(),
          target_errors: %{Ecto.UUID.t() => String.t()}
        }
end

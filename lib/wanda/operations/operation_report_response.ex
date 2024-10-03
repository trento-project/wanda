defmodule Wanda.Operations.OperationReportResponse do
  @moduledoc """
  """

  @derive Jason.Encoder
  defstruct [
    :diff
  ]

  @type t :: %__MODULE__{
          diff: map()
        }
end

defmodule Wanda.Execution.Result do
  @moduledoc """
  Represents the result of an execution.
  """

  alias Wanda.Execution.CheckResult

  @derive Jason.Encoder
  defstruct [
    :execution_id,
    :group_id,
    :check_results,
    :result
  ]

  @type t :: %__MODULE__{
          execution_id: String.t(),
          group_id: String.t(),
          check_results: [CheckResult.t()],
          result: :passing | :warning | :critical
        }
end

defmodule Wanda.Executions.Result do
  @moduledoc """
  Represents the result of an execution.
  """

  alias Wanda.Executions.CheckResult

  @derive Jason.Encoder
  defstruct [
    :execution_id,
    :group_id,
    :result,
    check_results: [],
    timeout: []
  ]

  @type t :: %__MODULE__{
          execution_id: String.t(),
          group_id: String.t(),
          check_results: [CheckResult.t()],
          timeout: [String.t()],
          result: :passing | :warning | :critical
        }
end

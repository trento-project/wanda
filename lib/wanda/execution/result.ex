defmodule Wanda.Execution.Result do
  @moduledoc """
  Represents the result of an execution.
  """

  alias Wanda.Execution.CheckResult

  defstruct [
    :execution_id,
    :group_id,
    :checks_result,
    :result
  ]

  @type t :: %__MODULE__{
          execution_id: String.t(),
          group_id: String.t(),
          checks_result: [CheckResult.t()],
          result: String.t()
        }
end

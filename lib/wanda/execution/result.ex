defmodule Wanda.Execution.Result do
  @moduledoc """
  Represents the result of an execution.
  """

  alias Wanda.Execution.CheckResult

  @derive {Jason.Encoder, except: [:execution_id, :group_id]}
  defstruct [
    :execution_id,
    :group_id,
    :check_results,
    :timeout,
    :result
  ]

  @type t :: %__MODULE__{
          execution_id: String.t(),
          group_id: String.t(),
          check_results: [CheckResult.t()],
          timeout: [String.t()],
          result: :passing | :warning | :critical
        }
end

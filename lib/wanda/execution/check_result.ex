defmodule Wanda.Execution.CheckResult do
  @moduledoc """
  Represents the result of check.
  """

  alias Wanda.Execution.ExpectationResult

  defstruct [
    :check_id,
    :expectations_results,
    :facts,
    :result
  ]

  @type t :: %__MODULE__{
          check_id: String.t(),
          expectations_results: [ExpectationResult.t()],
          facts: %{(name :: String.t()) => result :: any()},
          result: :passing | :warning | :critical
        }
end

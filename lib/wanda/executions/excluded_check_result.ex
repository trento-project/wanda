defmodule Wanda.Executions.ExcludedCheckResult do
  @moduledoc """
  Represents a (check, agent) pair excluded by the check's `exclude` predicate.
  """

  @derive Jason.Encoder
  defstruct [:check_id, :agent_id, :status, :exclude_expression]

  @type t :: %__MODULE__{
          check_id: String.t(),
          agent_id: String.t(),
          status: :excluded_by_policy,
          exclude_expression: String.t() | nil
        }
end

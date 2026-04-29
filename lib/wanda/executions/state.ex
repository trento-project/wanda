defmodule Wanda.Executions.State do
  @moduledoc """
  State of an execution.
  """

  alias Wanda.Catalog.SelectedCheck
  alias Wanda.Executions.{ExcludedCheckResult, Target}

  defstruct [
    :engine,
    :execution_id,
    :group_id,
    :timeout,
    targets: [],
    checks: [],
    env: %{},
    gathered_facts: %{},
    agents_gathered: [],
    excluded_checks: []
  ]

  @type t :: %__MODULE__{
          engine: Rhai.Engine.t(),
          execution_id: String.t(),
          group_id: String.t(),
          timeout: integer(),
          targets: [Target.t()],
          checks: [SelectedCheck.t()],
          env: %{String.t() => boolean() | number() | String.t()},
          gathered_facts: map(),
          agents_gathered: [String.t()],
          excluded_checks: [ExcludedCheckResult.t()]
        }
end

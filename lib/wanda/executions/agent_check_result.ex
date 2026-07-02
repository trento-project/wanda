# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: Apache-2.0

defmodule Wanda.Executions.AgentCheckResult do
  @moduledoc """
  Represents the result of a check on a specific agent.
  """

  alias Wanda.Executions.{
    ExpectationEvaluation,
    ExpectationEvaluationError,
    Fact,
    Value
  }

  @derive Jason.Encoder
  defstruct [
    :agent_id,
    :status,
    :exclude_expression,
    values: [],
    facts: [],
    expectation_evaluations: []
  ]

  @type status :: :excluded_by_policy | nil

  @type t :: %__MODULE__{
          agent_id: String.t(),
          status: status(),
          exclude_expression: String.t() | nil,
          facts: [Fact.t()],
          values: [Value.t()],
          expectation_evaluations: [ExpectationEvaluation.t() | ExpectationEvaluationError.t()]
        }
end

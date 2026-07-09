# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: Apache-2.0

defmodule Wanda.Executions.ExcludedCheckResult do
  @moduledoc """
  Represents a (check, agent) pair excluded by the check's `exclude` predicate.
  """

  require Wanda.Executions.Enums.AgentCheckStatus, as: AgentCheckStatus

  @derive Jason.Encoder
  defstruct [:check_id, :agent_id, :status, :exclude_expression]

  @type t :: %__MODULE__{
          check_id: String.t(),
          agent_id: String.t(),
          status: AgentCheckStatus.t(),
          exclude_expression: String.t() | nil
        }
end

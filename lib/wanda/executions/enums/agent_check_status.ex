# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: Apache-2.0

defmodule Wanda.Executions.Enums.AgentCheckStatus do
  @moduledoc """
  Type that represents an agent check execution status.
  """

  use Wanda.Support.Enum, values: [:executed, :excluded]
end

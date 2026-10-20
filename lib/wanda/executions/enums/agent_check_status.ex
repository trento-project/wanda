# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule Wanda.Executions.Enums.AgentCheckStatus do
  @moduledoc """
  Type that represents an agent check execution status.
  """

  use Wanda.Support.Enum, values: [:executed, :excluded]
end

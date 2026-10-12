# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule Wanda.Executions.Enums.Status do
  @moduledoc """
  Type that represents a check execution status.
  """

  use Wanda.Support.Enum, values: [:running, :completed]
end

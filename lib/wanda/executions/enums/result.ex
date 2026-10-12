# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule Wanda.Executions.Enums.Result do
  @moduledoc """
  Type that represents a check execution result.
  """

  use Wanda.Support.Enum, values: [:passing, :warning, :critical]
end

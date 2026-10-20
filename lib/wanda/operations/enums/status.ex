# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule Wanda.Operations.Enums.Status do
  @moduledoc """
  Type that represents an operation execution status.
  """

  use Wanda.Support.Enum,
    values: [:running, :completed, :aborted]
end

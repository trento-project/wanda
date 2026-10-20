# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule Wanda.Catalog.Enums.Severity do
  @moduledoc """
  Type that represents a check severity.
  """

  use Wanda.Support.Enum, values: [:warning, :critical]
end

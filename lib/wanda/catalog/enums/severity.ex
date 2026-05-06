# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: Apache-2.0

defmodule Wanda.Catalog.Enums.Severity do
  @moduledoc """
  Type that represents a check severity.
  """

  use Wanda.Support.Enum, values: [:warning, :critical]
end

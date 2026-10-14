# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule Wanda.Catalog.Enums.ExpectType do
  @moduledoc """
  Type that represents a check expectation type.
  """

  use Wanda.Support.Enum, values: [:expect, :expect_same, :expect_enum]
end

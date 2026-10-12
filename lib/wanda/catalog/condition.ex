# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule Wanda.Catalog.Condition do
  @moduledoc """
  Represents a condition.
  """

  @derive Jason.Encoder
  defstruct [:value, :expression]

  @type t :: %__MODULE__{
          value: boolean() | number() | String.t(),
          expression: String.t()
        }
end

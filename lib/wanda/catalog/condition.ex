# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: Apache-2.0

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

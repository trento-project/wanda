# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule Wanda.Catalog.Fact do
  @moduledoc """
  Represents a fact.
  """

  @derive Jason.Encoder
  defstruct [:name, :gatherer, :argument]

  @type t :: %__MODULE__{
          name: String.t(),
          gatherer: String.t(),
          argument: String.t()
        }
end

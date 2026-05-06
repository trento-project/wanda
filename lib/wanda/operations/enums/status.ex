# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: Apache-2.0

defmodule Wanda.Operations.Enums.Status do
  @moduledoc """
  Type that represents an operation execution status.
  """

  use Wanda.Support.Enum,
    values: [:running, :completed, :aborted]
end

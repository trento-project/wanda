# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: Apache-2.0

defmodule Wanda.Operations.Enums.OperatorPhase do
  @moduledoc """
  Type that represents an operator phase.
  """

  use Wanda.Support.Enum,
    values: [:plan, :commit, :verify, :rollback]
end

# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: Apache-2.0

defmodule Wanda.Operations.Enums.Result do
  @moduledoc """
  Type that represents an operation result.
  """

  use Wanda.Support.Enum,
    values: [:updated, :not_updated, :failed, :rolled_back, :timeout, :skipped, :not_executed]
end

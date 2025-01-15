defmodule Wanda.Expectations.Enums.Result do
  @moduledoc """
  Type that represents a check execution result.
  """

  use Wanda.Support.Enum, values: [:passing, :warning, :critical]
end

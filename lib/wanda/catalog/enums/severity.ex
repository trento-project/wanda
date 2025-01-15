defmodule Wanda.Catalog.Enums.Severity do
  @moduledoc """
  Type that represents a check severity.
  """

  use Wanda.Support.Enum, values: [:warning, :critical]
end

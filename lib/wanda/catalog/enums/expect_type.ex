defmodule Wanda.Catalog.Enums.ExpectType do
  @moduledoc """
  Type that represents a check expectation type.
  """

  use Wanda.Support.Enum, values: [:expect, :expect_same, :expect_enum]
end

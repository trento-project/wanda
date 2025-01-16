defmodule Wanda.Operations.Enums.Status do
  @moduledoc """
  Type that represents an operation execution status.
  """

  use Wanda.Support.Enum,
    values: [:running, :completed]
end

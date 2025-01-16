defmodule Wanda.Executions.Enums.Status do
  @moduledoc """
  Type that represents a check execution status.
  """

  use Wanda.Support.Enum, values: [:running, :completed]
end

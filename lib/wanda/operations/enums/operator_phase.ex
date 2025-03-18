defmodule Wanda.Operations.Enums.OperatorPhase do
  @moduledoc """
  Type that represents an operator phase.
  """

  use Wanda.Support.Enum,
    values: [:plan, :commit, :verify, :rollback]
end

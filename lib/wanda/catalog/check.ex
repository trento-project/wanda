defmodule Wanda.Catalog.Check do
  @moduledoc """
  Represents a check.
  """

  alias Wanda.Catalog.{Expectation, Fact}

  defstruct [:id, :name, :severity, :facts, :expectations]

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          severity: :warning | :critical,
          facts: [Fact.t()],
          expectations: [Expectation.t()]
        }
end

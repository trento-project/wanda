defmodule Wanda.Catalog.Check do
  @moduledoc """
  Represents a check.
  """

  alias Wanda.Catalog.{Expectation, Fact}

  defstruct [:id, :name, :facts, :expectations]

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          facts: [Fact.t()],
          expectations: [Expectation.t()]
        }
end

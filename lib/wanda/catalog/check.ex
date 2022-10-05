defmodule Wanda.Catalog.Check do
  @moduledoc """
  Represents a check.
  """

  alias Wanda.Catalog.{Expectation, Fact, Value}

  defstruct [:id, :name, :severity, :facts, :values, :expectations]

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          severity: :warning | :critical,
          facts: [Fact.t()],
          values: [Value.t()],
          expectations: [Expectation.t()]
        }
end

defmodule Wanda.Catalog.Value do
  @moduledoc """
  Represents a value.
  """

  alias Wanda.Catalog.Condition

  defstruct [:name, :default, :conditions]

  @type t :: %__MODULE__{
          name: String.t(),
          default: boolean() | number() | String.t(),
          conditions: [Condition.t()]
        }
end

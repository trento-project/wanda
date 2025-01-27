defmodule Wanda.Catalog.Value do
  @moduledoc """
  Represents a value.
  """

  alias Wanda.Catalog.Condition

  @derive Jason.Encoder
  defstruct [:name, :default, :conditions, :customizable]

  @type t :: %__MODULE__{
          name: String.t(),
          default: boolean() | number() | String.t(),
          conditions: [Condition.t()],
          customizable: boolean()
        }
end

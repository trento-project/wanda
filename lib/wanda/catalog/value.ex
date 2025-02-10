defmodule Wanda.Catalog.Value do
  @moduledoc """
  Represents a value.
  """

  alias Wanda.Catalog.Condition

  @derive Jason.Encoder
  defstruct [:name, :default, :conditions, :customization_disabled]

  @type t :: %__MODULE__{
          name: String.t(),
          default: boolean() | number() | String.t(),
          conditions: [Condition.t()],
          customization_disabled: boolean()
        }
end

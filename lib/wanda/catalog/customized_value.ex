defmodule Wanda.Catalog.CustomizedValue do
  @moduledoc """
  Represents a check's customized value.
  """

  defstruct [:name, :value]

  @type t :: %__MODULE__{
          name: String.t(),
          value: boolean() | number() | String.t()
        }

  def from_custom_value(%{name: name, value: value}) do
    %__MODULE__{
      name: name,
      value: value
    }
  end
end

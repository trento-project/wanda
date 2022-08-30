defmodule Wanda.Catalog.Fact do
  @moduledoc """
  Represents a Fact Definition of a Check in the Catalog.
  """

  @derive Jason.Encoder
  defstruct [:check_id, :name, :gatherer, :argument]

  @type t :: %__MODULE__{
          check_id: String.t(),
          name: String.t(),
          gatherer: String.t(),
          argument: String.t()
        }
end

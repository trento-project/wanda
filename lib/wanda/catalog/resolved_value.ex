defmodule Wanda.Catalog.ResolvedValue do
  @moduledoc """
  Represents a resolved check value as defined check specification.
  It is based on the contextual environment.
  """
  alias Wanda.Catalog.Value

  @type value :: boolean() | number() | String.t()

  @derive Jason.Encoder
  defstruct [
    :spec,
    :name,
    :default_value,
    :custom_value,
    :customized
  ]

  @type t :: %__MODULE__{
          spec: Value.t(),
          name: String.t(),
          default_value: value(),
          custom_value: value(),
          customized: boolean()
        }
end

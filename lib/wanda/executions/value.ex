defmodule Wanda.Executions.Value do
  @moduledoc """
  Represents a Value used in expectation evaluation.
  This value has been already determined given the conditions in check definition.
  """
  alias Wanda.Catalog.ResolvedValue

  @derive Jason.Encoder
  defstruct [
    :name,
    :value,
    :customized
  ]

  @type t :: %__MODULE__{
          name: String.t(),
          value: boolean() | number() | String.t(),
          customized: boolean()
        }

  def from_resolved_value(%ResolvedValue{
        name: name,
        original_value: value,
        customized: false
      }) do
    %__MODULE__{
      name: name,
      value: value,
      customized: false
    }
  end

  def from_resolved_value(%ResolvedValue{
        name: name,
        custom_value: value,
        customized: true
      }) do
    %__MODULE__{
      name: name,
      value: value,
      customized: true
    }
  end
end

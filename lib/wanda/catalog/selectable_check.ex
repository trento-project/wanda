defmodule Wanda.Catalog.SelectableCheck do
  @moduledoc """
  Represents a check that is selectable for a given execution group given the context.
  """

  @type customized_value :: %{
          name: String.t(),
          customizable: true,
          original_value: boolean() | number() | String.t(),
          custom_value: boolean() | number() | String.t()
        }

  @type non_customized_value :: %{
          name: String.t(),
          customizable: boolean(),
          original_value: boolean() | number() | String.t()
        }

  @derive Jason.Encoder
  defstruct [
    :id,
    :name,
    :group,
    :description,
    :values,
    :customizable,
    :customized
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          group: String.t(),
          customizable: boolean(),
          description: String.t(),
          values: [non_customized_value() | customized_value()],
          customized: boolean()
        }
end

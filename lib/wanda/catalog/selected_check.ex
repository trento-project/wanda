defmodule Wanda.Catalog.SelectedCheck do
  @moduledoc """
  Represents a selected check used during a check execution.

  It carries information about the check specification and its available customizations.
  """

  alias Wanda.Catalog.{Check, CustomizedValue}

  defstruct [
    :id,
    :spec,
    :customized,
    :customizations
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          spec: Check.t(),
          customized: boolean(),
          customizations: [CustomizedValue.t()]
        }

  @spec extract_specs([t]) :: [Check.t()]
  def extract_specs(selected_checks), do: Enum.map(selected_checks, & &1.spec)
end

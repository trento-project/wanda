defmodule Wanda.Catalog.Check do
  @moduledoc """
  Represents a check.
  """

  alias Wanda.Catalog.{Expectation, Fact, Value}

  require Wanda.Catalog.Enums.Severity, as: Severity

  @derive Jason.Encoder
  defstruct [
    :id,
    :name,
    :group,
    :description,
    :remediation,
    :metadata,
    :severity,
    :facts,
    :values,
    :expectations,
    :when,
    :customizable
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          group: String.t(),
          customizable: boolean(),
          description: String.t(),
          remediation: String.t(),
          metadata: map(),
          severity: Severity.t(),
          facts: [Fact.t()],
          values: [Value.t()],
          expectations: [Expectation.t()],
          when: String.t()
        }
end

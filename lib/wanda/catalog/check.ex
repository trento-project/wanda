defmodule Wanda.Catalog.Check do
  @moduledoc """
  Represents a check.
  """

  alias Wanda.Catalog.{Expectation, Fact, Value}

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
    :premium
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          group: String.t(),
          description: String.t(),
          remediation: String.t(),
          metadata: map(),
          severity: :warning | :critical,
          facts: [Fact.t()],
          values: [Value.t()],
          expectations: [Expectation.t()],
          when: String.t(),
          premium: boolean()
        }
end

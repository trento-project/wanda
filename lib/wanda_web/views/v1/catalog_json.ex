defmodule WandaWeb.V1.CatalogJSON do
  alias Wanda.Catalog.Check

  def catalog(%{catalog: catalog}) do
    %{items: Enum.map(catalog, &check/1)}
  end

  def check(
        %Check{
          id: id,
          name: name,
          group: group,
          description: description,
          remediation: remediation,
          metadata: metadata,
          severity: severity,
          facts: facts,
          values: values,
          when: when_expression
        } = check
      ) do
    adapted_expectations = adapt_expectations(check)

    %{
      id: id,
      name: name,
      group: group,
      description: description,
      remediation: remediation,
      metadata: metadata,
      severity: severity,
      facts: facts,
      values: values,
      expectations: adapted_expectations,
      when: when_expression,
      premium: false
    }
  end

  def adapt_expectations(%{expectations: expectations}) do
    expectations
    |> Enum.map(fn
      %{type: :expect_enum} = expectation -> Map.put(expectation, :type, :unknown)
      expectation -> expectation
    end)
    |> Enum.map(&Map.drop(Map.from_struct(&1), [:warning_message]))
  end
end

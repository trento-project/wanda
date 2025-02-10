defmodule WandaWeb.V1.CatalogJSON do
  alias Wanda.Catalog.{Check, SelectableCheck}

  def catalog(%{catalog: catalog}) do
    %{items: Enum.map(catalog, &check/1)}
  end

  def selectable_checks(%{
        selectable_checks: selectable_checks
      }) do
    %{
      items: Enum.map(selectable_checks, &selectable_check/1)
    }
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
    adapted_values = adapt_values_customizability(values)

    %{
      id: id,
      name: name,
      group: group,
      description: description,
      remediation: remediation,
      metadata: metadata,
      severity: severity,
      facts: facts,
      values: adapted_values,
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

  def adapt_values_customizability(values) do
    Enum.map(values, &(&1 |> Map.from_struct() |> Map.drop([:disable_customization])))
  end

  defp selectable_check(%SelectableCheck{
         id: id,
         name: name,
         group: group,
         description: description,
         values: values,
         customizable: customizable,
         customized: customized
       }) do
    %{
      id: id,
      name: name,
      group: group,
      description: description,
      values: values,
      customizable: customizable,
      customized: customized
    }
  end
end

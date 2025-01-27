defmodule WandaWeb.V3.CatalogJSON do
  alias Wanda.Catalog.Check

  alias WandaWeb.V1.CatalogJSON

  def catalog(%{catalog: catalog}) do
    %{items: Enum.map(catalog, &check/1)}
  end

  def check(%Check{
        id: id,
        name: name,
        group: group,
        description: description,
        remediation: remediation,
        metadata: metadata,
        severity: severity,
        facts: facts,
        values: values,
        expectations: expectations,
        when: when_expression
      }) do
    %{
      id: id,
      name: name,
      group: group,
      description: description,
      remediation: remediation,
      metadata: metadata,
      severity: severity,
      facts: facts,
      values: CatalogJSON.adapt_values_customizability(values),
      expectations: expectations,
      when: when_expression,
      premium: false
    }
  end
end

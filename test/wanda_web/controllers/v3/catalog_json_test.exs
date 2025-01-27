defmodule WandaWeb.V3.CatalogJSONTest do
  use WandaWeb.ConnCase, async: true

  import Wanda.Factory

  alias Wanda.Catalog.Check

  alias WandaWeb.V3.CatalogJSON

  describe "CatalogJSON" do
    test "renders catalog.json" do
      [
        %Check{
          id: id,
          name: name,
          group: group,
          description: description,
          remediation: remediation,
          metadata: metadata,
          severity: severity,
          facts: facts,
          values: _values,
          expectations: expectations,
          when: when_expression
        }
      ] = checks = build_list(1, :check)

      assert %{
               items: [
                 %{
                   id: ^id,
                   name: ^name,
                   group: ^group,
                   description: ^description,
                   remediation: ^remediation,
                   metadata: ^metadata,
                   severity: ^severity,
                   facts: ^facts,
                   values: exposed_values,
                   expectations: ^expectations,
                   when: ^when_expression,
                   premium: false
                 } = exposed_check
               ]
             } = CatalogJSON.catalog(%{catalog: checks})

      refute Map.has_key?(exposed_check, :customizable)
      refute Enum.any?(exposed_values, fn value -> Map.has_key?(value, :customizable) end)
    end
  end
end

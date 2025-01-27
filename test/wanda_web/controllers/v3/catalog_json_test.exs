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
          values: values,
          expectations: expectations,
          when: when_expression,
          customizable: customizable
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
                   values: ^values,
                   expectations: ^expectations,
                   when: ^when_expression,
                   premium: false,
                   customizable: ^customizable
                 }
               ]
             } = CatalogJSON.catalog(%{catalog: checks})

      assert Enum.all?(values, fn value -> Map.has_key?(value, :customizable) end)
    end
  end
end

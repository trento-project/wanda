defmodule WandaWeb.V2.CatalogJSONTest do
  use WandaWeb.ConnCase, async: true

  import Wanda.Factory

  alias WandaWeb.V2.CatalogJSON

  describe "CatalogJSON" do
    test "renders catalog.json" do
      checks = [
        build(:check, expectations: build_list(2, :catalog_expectation, type: :expect)),
        build(:check, expectations: build_list(2, :catalog_expectation, type: :expect_same))
      ]

      %{items: rendered_catalog} = CatalogJSON.catalog(%{catalog: checks})

      assert Enum.all?(
               rendered_catalog,
               fn check -> Map.has_key?(check, :premium) and Map.get(check, :premium) == false end
             )

      assert Enum.all?(rendered_catalog, fn %{expectations: expectations} ->
               Enum.all?(expectations, &(not Map.has_key?(&1, :warning_message)))
             end)
    end
  end

  describe "adapt to V2 version" do
    test "should remove checks with expect_enum expectations" do
      checks =
        build_list(1, :check,
          expectations: build_list(1, :catalog_expectation, type: :expect_enum)
        )

      assert %{
               items: [
                 %{
                   expectations: [
                     %{type: :unknown}
                   ]
                 }
               ]
             } =
               CatalogJSON.catalog(%{catalog: checks})
    end

    test "should not expose customizability information" do
      checks = build_list(1, :check)

      %{
        items: [%{values: values} = rendered_check_json]
      } = CatalogJSON.catalog(%{catalog: checks})

      refute Map.has_key?(rendered_check_json, :customizable)
      refute Enum.any?(values, fn value -> Map.has_key?(value, :customizable) end)
    end
  end
end

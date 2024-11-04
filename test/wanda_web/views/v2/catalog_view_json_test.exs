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

      adapted_checks =
        Enum.map(checks, fn %{expectations: expectations} = check ->
          %{
            check
            | expectations:
                Enum.map(expectations, fn expectation ->
                  expectation
                  |> Map.from_struct()
                  |> Map.drop([:warning_message])
                end)
          }
          |> Map.from_struct()
          |> Map.put(:premium, false)
        end)

      rendered_catalog = CatalogJSON.catalog(%{catalog: checks})

      assert %{
               items: ^adapted_checks
             } = rendered_catalog
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
  end
end
defmodule WandaWeb.V1.CatalogViewTest do
  use WandaWeb.ConnCase, async: true

  import Phoenix.View
  import Wanda.Factory

  alias Wanda.Catalog.Check
  alias WandaWeb.V1.CatalogView

  describe "CatalogView" do
    test "renders catalog.json" do
      checks = [
        build(:check, expectations: build_list(2, :catalog_expectation, type: :expect)),
        build(:check, expectations: build_list(2, :catalog_expectation, type: :expect_same))
      ]

      adapted_checks =
        Enum.map(checks, fn %Check{expectations: expectations} = check ->
          %{
            check
            | expectations:
                Enum.map(expectations, fn expectation ->
                  expectation
                  |> Map.from_struct()
                  |> Map.drop([:warning_message])
                end)
          }
        end)

      rendered_catalog = render(CatalogView, "catalog.json", catalog: checks)

      assert %{
               items: ^adapted_checks
             } = rendered_catalog
    end
  end

  describe "adapt to V1 version" do
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
             } = render(CatalogView, "catalog.json", catalog: checks)
    end

    test "should remove warning_message in check expectations" do
      checks = build_list(1, :check)

      %{
        items: [%Check{expectations: [expectation | _rest_expectations]}]
      } =
        render(CatalogView, "catalog.json", catalog: checks)

      refute Map.has_key?(expectation, :warning_message)
    end
  end
end

defmodule WandaWeb.V1.CatalogViewTest do
  use WandaWeb.ConnCase, async: true

  import Phoenix.View
  import Wanda.Factory

  alias WandaWeb.V1.CatalogView

  describe "CatalogView" do
    test "renders catalog.json" do
      checks = [
        build(:check, expectations: build_list(2, :catalog_expectation, type: :expect)),
        build(:check, expectations: build_list(2, :catalog_expectation, type: :expect_same))
      ]

      updated_checks =
        Enum.map(checks, fn check ->
          updated_expectations =
            Enum.map(check.expectations, fn %{
                                              name: name,
                                              type: type,
                                              expression: expression,
                                              failure_message: failure_message
                                            } ->
              %{name: name, type: type, expression: expression, failure_message: failure_message}
            end)

          %{check | expectations: updated_expectations}
        end)

      rendered_catalog = render(CatalogView, "catalog.json", catalog: checks)

      assert %{
               items: ^updated_checks
             } = rendered_catalog
    end
  end

  test "renders catalog.json like expected in the v1 schema" do
    checks = [
      build(:check, expectations: build_list(2, :catalog_expectation, type: :expect)),
      build(:check, expectations: build_list(2, :catalog_expectation, type: :expect_same))
    ]

    rendered_catalog = render(CatalogView, "catalog.json", catalog: checks)
    refute Access.get(rendered_catalog, :warning_message)
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
  end
end

defmodule WandaWeb.CatalogViewTest do
  use WandaWeb.ConnCase, async: true

  import Phoenix.View
  import Wanda.Factory

  describe "CatalogView" do
    test "renders list_catalog.json" do
      checks = build_list(3, :check)

      assert %{
               data: ^checks
             } = render(WandaWeb.CatalogView, "list_catalog.json", catalog: checks)
    end
  end
end

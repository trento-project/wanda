defmodule WandaWeb.V2.CatalogViewTest do
  use WandaWeb.ConnCase, async: true

  import Phoenix.View
  import Wanda.Factory

  alias WandaWeb.V2.CatalogView

  describe "CatalogView" do
    test "renders catalog.json" do
      checks = build_list(3, :check)

      assert %{
               items: ^checks
             } = render(CatalogView, "catalog.json", catalog: checks)
    end
  end
end

defmodule WandaWeb.V3.CatalogJSONTest do
  use WandaWeb.ConnCase, async: true

  import Wanda.Factory

  alias WandaWeb.V3.CatalogJSON

  describe "CatalogJSON" do
    test "renders catalog.json" do
      checks = build_list(1, :check)

      assert %{
               items: ^checks
             } = CatalogJSON.catalog(%{catalog: checks})
    end
  end
end

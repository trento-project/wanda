defmodule WandaWeb.CatalogControllerTest do
  use WandaWeb.ConnCase, async: true
  import OpenApiSpex.TestAssertions

  alias WandaWeb.ApiSpec

  describe "CatalogController" do
    test "listing the checks catalog produces a CatalogResponse", %{conn: conn} do
      json =
        conn
        |> get(Routes.catalog_path(conn, :list_catalog))
        |> json_response(200)

      api_spec = ApiSpec.spec()
      assert_schema(json, "CatalogResponse", api_spec)
    end
  end
end

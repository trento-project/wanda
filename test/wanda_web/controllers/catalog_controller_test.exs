defmodule WandaWeb.CatalogControllerTest do
  use WandaWeb.ConnCase, async: true
  import OpenApiSpex.TestAssertions

  alias WandaWeb.ApiSpec

  describe "CatalogController" do
    test "listing the checks catalog produces a CatalogResponse", %{conn: conn} do
      json =
        conn
        |> get("/api/checks/catalog")
        |> json_response(200)

      api_spec = ApiSpec.spec()
      assert_schema(json, "CatalogResponse", api_spec)
    end

    test "listing the checks catalog produces a CatalogResponse when filtered", %{conn: conn} do
      json =
        conn
        |> get("/api/checks/catalog?provider=azure&foo=bar")
        |> json_response(200)

      api_spec = ApiSpec.spec()
      assert_schema(json, "CatalogResponse", api_spec)
    end
  end
end

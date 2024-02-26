defmodule WandaWeb.V1.CatalogControllerTest do
  use WandaWeb.ConnCase, async: true
  import OpenApiSpex.TestAssertions

  alias WandaWeb.Schemas.V1.ApiSpec

  describe "CatalogController" do
    test "listing the checks catalog produces a CatalogResponse", %{conn: conn} do
      json =
        conn
        |> get("/api/v1/checks/catalog")
        |> json_response(200)

      api_spec = ApiSpec.spec()
      assert_schema(json, "CatalogResponse", api_spec)
    end

    test "listing the checks catalog produces a CatalogResponse when filtered", %{conn: conn} do
      json =
        conn
        |> get("/api/v1/checks/catalog?provider=azure&foo=bar")
        |> json_response(200)

      assert %{
               "items" => [
                 %{"id" => "expect_check"},
                 %{"id" => "expect_enum_check"},
                 %{"id" => "expect_same_check"},
                 %{"id" => "warning_severity_check"},
                 %{"id" => "when_condition_check"},
                 %{"id" => "with_metadata"}
               ]
             } = json

      api_spec = ApiSpec.spec()
      assert_schema(json, "CatalogResponse", api_spec)
    end

    test "does not accept different types inside the env", %{conn: conn} do
      json =
        conn
        |> get("/api/v1/checks/catalog?provider=azure&foo=true")
        |> json_response(422)

      assert %{
               "errors" => [
                 %{
                   "detail" => _,
                   "title" => _,
                   "source" => _
                 }
                 | _
               ]
             } = json
    end
  end
end

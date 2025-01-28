defmodule WandaWeb.V2.CatalogControllerTest do
  use WandaWeb.ConnCase, async: false
  use Wanda.Support.CatalogCase

  import OpenApiSpex.TestAssertions

  alias WandaWeb.Schemas.V2.ApiSpec

  describe "CatalogController" do
    test "listing the checks catalog produces a CatalogResponse", %{conn: conn} do
      json =
        conn
        |> get("/api/v2/checks/catalog")
        |> json_response(200)

      api_spec = ApiSpec.spec()
      assert_schema(json, "CatalogResponse", api_spec)
    end

    test "listing the checks catalog produces a CatalogResponse when filtered", %{conn: conn} do
      json =
        conn
        |> get("/api/v2/checks/catalog?provider=azure&foo=bar")
        |> json_response(200)

      assert %{
               "items" => [
                 %{"id" => "check_without_values"},
                 %{"id" => "customizable_check"},
                 %{"id" => "expect_check"},
                 %{"id" => "expect_enum_check"},
                 %{"id" => "expect_same_check"},
                 %{"id" => "non_customizable_check"},
                 %{"id" => "non_customizable_check_values"},
                 %{"id" => "warning_severity_check"},
                 %{"id" => "when_condition_check"},
                 %{"id" => "with_metadata"}
               ]
             } = json

      api_spec = ApiSpec.spec()
      assert_schema(json, "CatalogResponse", api_spec)
    end

    test "accepts different types inside the env", %{conn: conn} do
      json =
        conn
        |> get("/api/v2/checks/catalog?provider=azure&foo=true")
        |> json_response(200)

      assert %{
               "items" => [
                 %{"id" => "check_without_values"},
                 %{"id" => "customizable_check"},
                 %{"id" => "expect_check"},
                 %{"id" => "expect_enum_check"},
                 %{"id" => "expect_same_check"},
                 %{"id" => "non_customizable_check"},
                 %{"id" => "non_customizable_check_values"},
                 %{"id" => "warning_severity_check"},
                 %{"id" => "when_condition_check"},
                 %{"id" => "with_metadata"}
               ]
             } = json

      api_spec = ApiSpec.spec()
      assert_schema(json, "CatalogResponse", api_spec)
    end
  end
end

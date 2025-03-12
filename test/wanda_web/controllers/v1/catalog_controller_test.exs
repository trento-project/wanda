defmodule WandaWeb.V1.CatalogControllerTest do
  use WandaWeb.ConnCase, async: false
  use Wanda.Support.CatalogCase

  import Wanda.Factory

  import OpenApiSpex.TestAssertions

  alias WandaWeb.Schemas.V1.ApiSpec

  setup do
    %{api_spec: ApiSpec.spec()}
  end

  describe "CatalogController" do
    test "listing the checks catalog produces a CatalogResponse", %{
      conn: conn,
      api_spec: api_spec
    } do
      json =
        conn
        |> get("/api/v1/checks/catalog")
        |> json_response(200)

      assert_schema(json, "CatalogResponse", api_spec)
    end

    test "listing the checks catalog produces a CatalogResponse when filtered", %{
      conn: conn,
      api_spec: api_spec
    } do
      json =
        conn
        |> get("/api/v1/checks/catalog?provider=azure&foo=bar")
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

  describe "checks selection" do
    test "should return checks selection with no custom values when customizations are not available",
         %{conn: conn, api_spec: api_spec} do
      %{items: selectable_checks} =
        conn
        |> get("/api/v1/groups/#{Faker.UUID.v4()}/checks", %{})
        |> json_response(:ok)
        |> assert_schema("SelectableChecksResponse", api_spec)

      assert length(selectable_checks) == 10
      refute Enum.any?(selectable_checks, & &1.customized)
    end

    test "should return checks selection with customized values",
         %{conn: conn, api_spec: api_spec} do
      customized_check_id = "customizable_check"

      scenarios = [
        %{
          group_id: Faker.UUID.v4(),
          numeric_value: 420,
          expected_customization: 420
        },
        %{
          group_id: Faker.UUID.v4(),
          numeric_value: 420.1,
          expected_customization: 420.1
        }
      ]

      for %{
            group_id: group_id,
            numeric_value: numeric_value,
            expected_customization: expected_customization
          } <- scenarios do
        insert(:check_customization,
          group_id: group_id,
          check_id: customized_check_id,
          custom_values: [
            %{
              name: "expected_value",
              value: numeric_value
            }
          ]
        )

        %{items: selectable_checks} =
          conn
          |> get("/api/v1/groups/#{group_id}/checks", %{})
          |> json_response(:ok)
          |> assert_schema("SelectableChecksResponse", api_spec)

        assert length(selectable_checks) == 10

        assert selectable_checks
               |> Enum.filter(& &1.customized)
               |> length() == 1

        assert selectable_checks
               |> Enum.filter(&(not &1.customized))
               |> length() == 9

        %{
          values: customized_check_values,
          customized: true
        } = Enum.find(selectable_checks, &(&1.id == customized_check_id))

        assert [
                 %{
                   name: "expected_value",
                   customizable: true,
                   default_value: 5,
                   custom_value: ^expected_customization
                 },
                 %{
                   name: "expected_higher_value",
                   customizable: false
                 }
               ] = customized_check_values
      end
    end
  end
end
